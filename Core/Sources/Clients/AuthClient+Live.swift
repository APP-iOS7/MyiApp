import AuthenticationServices
import CryptoKit
import Domain
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

extension AuthClient {
    public static var live: Self {
        let appleIDProvider = ASAuthorizationAppleIDProvider()

        return Self(
            currentUser: { () async throws(AuthError) in
                guard let nativeUser = Auth.auth().currentUser else {
                    return nil
                }

                return Domain.User(
                    id: nativeUser.uid,
                    email: nativeUser.email ?? "",
                    name: nativeUser.displayName ?? "사용자",
                    imageURL: nativeUser.photoURL,
                    createdAt: Date(),
                    updatedAt: Date(),
                    loginProvider: .google // 실제 로그인 시 발급받은 제공자 처리
                )
            },
            login: { provider async throws(AuthError) in
                switch provider {
                case .google:
                    return try await googleSignIn()
                case .apple:
                    let nonce = randomNonceString()
                    let request = appleIDProvider.createRequest()
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = sha256(nonce)

                    do {
                        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<
                            Domain.User,
                            any Error
                        >) in
                            Task { @MainActor in
                                let delegate = AppleSignInDelegate { result in
                                    switch result {
                                    case let .success(credential):
                                        Task {
                                            do {
                                                let firebaseUser = try await signInToFirebase(
                                                    with: credential,
                                                    nonce: nonce
                                                )
                                                continuation.resume(returning: firebaseUser)
                                            } catch {
                                                continuation.resume(throwing: error)
                                            }
                                        }

                                    case let .failure(error):
                                        continuation.resume(throwing: error)
                                    }
                                }

                                let controller = ASAuthorizationController(authorizationRequests: [request])
                                controller.delegate = delegate
                                objc_setAssociatedObject(
                                    controller,
                                    "delegate",
                                    delegate,
                                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                                )
                                controller.performRequests()
                            }
                        }
                    } catch {
                        throw (error as? AuthError) ?? .unknown
                    }
                }
            },
            logout: { () async throws(AuthError) in
                do {
                    try Auth.auth().signOut()
                } catch {
                    throw AuthError.unknown
                }
            },
            deleteAccount: { () async throws(AuthError) in
                do {
                    if let user = Auth.auth().currentUser {
                        try await user.delete()
                    }
                } catch {
                    throw AuthError.unknown
                }
            }
        )
    }

    // MARK: - Private Methods

    private static func signInToFirebase(
        with appleIDCredential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws(AuthError)
        -> Domain.User
    {
        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AuthError.unknown
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.unknown
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            let nativeUser = authResult.user

            return Domain.User(
                id: nativeUser.uid,
                email: nativeUser.email ?? "",
                name: nativeUser.displayName ?? "사용자",
                imageURL: nativeUser.photoURL,
                createdAt: Date(),
                updatedAt: Date(),
                loginProvider: .apple
            )
        } catch {
            throw .unknown
        }
    }

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { charset[Int($0) % charset.count] }
        return String(nonce)
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    @MainActor
    private static func googleSignIn() async throws(AuthError) -> Domain.User {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            throw AuthError.unknown
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.unknown
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            let nativeUser = authResult.user

            return Domain.User(
                id: nativeUser.uid,
                email: nativeUser.email ?? "",
                name: nativeUser.displayName ?? "사용자",
                imageURL: nativeUser.photoURL,
                createdAt: Date(),
                updatedAt: Date(),
                loginProvider: .google
            )
        } catch let error as AuthError {
            throw error
        } catch {
            throw .unknown
        }
    }
}

// MARK: - Apple Login Delegate

@MainActor
private final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let completion: (Result<ASAuthorizationAppleIDCredential, Error>) -> Void

    init(completion: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.completion(.success(appleIDCredential))
        } else {
            self.completion(.failure(AuthError.unknown))
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        self.completion(.failure(error))
    }
}
