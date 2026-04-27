import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
import Foundation

extension AuthClient: @retroactive TestDependencyKey {}
extension AuthClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        current: { Auth.auth().currentUser.map { Session(user: $0) } },
        stateStream: {
            AsyncStream { continuation in
                let handle = Auth.auth().addStateDidChangeListener { _, user in
                    continuation.yield(user.map { Session(user: $0) })
                }
                continuation.onTermination = { _ in Auth.auth().removeStateDidChangeListener(handle) }
            }
        },
        signInWithApple: { @Sendable () async throws(AuthError) -> Session? in
            do {
                let provider = await AppleSignInProvider()
                let appleResult = try await provider.signIn()

                let credential = OAuthProvider.appleCredential(
                    withIDToken: appleResult.identityToken,
                    rawNonce: appleResult.rawNonce,
                    fullName: appleResult.fullName
                )

                let authResult = try await Auth.auth().signIn(with: credential)
                AppleAuthorizationCodeStore.save(appleResult.authorizationCode)
                return Session(user: authResult.user)
            } catch AppleSignInError.userCancelled {
                return nil
            } catch {
                throw AuthError.unexpected
            }
        },
        signInWithGoogle: { @Sendable () async throws(AuthError) -> Session? in
            do {
                let googleResult = try await GoogleSignInProvider.signIn()

                let credential = GoogleAuthProvider.credential(
                    withIDToken: googleResult.idToken,
                    accessToken: googleResult.accessToken
                )

                let authResult = try await Auth.auth().signIn(with: credential)
                return Session(user: authResult.user)
            } catch GoogleSignInError.userCancelled {
                return nil
            } catch {
                throw AuthError.unexpected
            }
        },
        signOut: { @Sendable () async throws(AuthError) in
            do {
                try Auth.auth().signOut()
            } catch {
                throw AuthError.unexpected
            }
        },
        deleteAccount: { @Sendable () async throws(AuthError) in
            guard let user = Auth.auth().currentUser else {
                return
            }

            do {
                let isAppleProvider = user.providerData.contains { $0.providerID == "apple.com" }
                if isAppleProvider, let authorizationCode = AppleAuthorizationCodeStore.load() {
                    try await Auth.auth().revokeToken(withAuthorizationCode: authorizationCode)
                }

                try await user.delete()
                AppleAuthorizationCodeStore.delete()
            } catch {
                let nsError = error as NSError
                if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    throw AuthError.requiresRecentLogin
                }
                throw AuthError.unexpected
            }
        }
    )
}

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

private extension Session {
    init(user: User) {
        self.init(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL,
            providerIDs: user.providerData.map(\.providerID),
            createdAt: user.metadata.creationDate ?? Date()
        )
    }
}
