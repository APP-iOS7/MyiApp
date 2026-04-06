import AuthenticationServices
import ComposableArchitecture
import CryptoKit

extension AppleSignInClient: DependencyKey {
    static let liveValue: AppleSignInClient = .init(
        signIn: {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            return try await withCheckedThrowingContinuation { continuation in
                let nonce = randomNonceString()
                request.nonce = sha256(nonce)

                let controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = AppleSignInDelegate(nonce: nonce, continuation: continuation)
                delegate.selfRetain = delegate
                controller.delegate = delegate
                controller.performRequests()
            }
        }
    )
}

extension DependencyValues {
    var appleSignInClient: AppleSignInClient {
        get { self[AppleSignInClient.self] }
        set { self[AppleSignInClient.self] = newValue }
    }
}

private nonisolated final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let nonce: String
    let continuation: CheckedContinuation<AppleCredential, Error>
    var selfRetain: AppleSignInDelegate?

    init(nonce: String, continuation: CheckedContinuation<AppleCredential, Error>) {
        self.nonce = nonce
        self.continuation = continuation
    }

    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = credential.identityToken,
              let idToken = String(data: idTokenData, encoding: .utf8)
        else {
            continuation.resume(throwing: AppleSignInError.invalidCredential)
            return
        }

        defer { selfRetain = nil }
        continuation.resume(returning: AppleCredential(
            idToken: idToken,
            nonce: nonce,
            givenName: credential.fullName?.givenName,
            familyName: credential.fullName?.familyName
        ))
    }

    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        defer { selfRetain = nil }
        continuation.resume(throwing: error)
    }
}

enum AppleSignInError: Error {
    case invalidCredential
}

private func randomNonceString(length: Int = 32) -> String {
    var randomBytes = [UInt8](repeating: 0, count: length)
    _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    return randomBytes.map { String(format: "%02x", $0) }.joined()
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}
