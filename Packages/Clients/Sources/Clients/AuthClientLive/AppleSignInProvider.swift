import AuthenticationServices
import UIKit

@MainActor
final class AppleSignInProvider: NSObject {
    private var continuation: CheckedContinuation<Result<AppleSignInResult, AppleSignInError>, Never>?
    private var rawNonce: String?

    func signIn() async throws(AppleSignInError) -> AppleSignInResult {
        let nonce: String
        do {
            nonce = try Nonce.random()
        } catch {
            throw AppleSignInError.unexpected(error)
        }

        rawNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Nonce.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        return try await withCheckedContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }.get()
    }
}

extension AppleSignInProvider: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer {
            continuation = nil
            rawNonce = nil
        }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(returning: .failure(.unexpectedCredentialType))
            return
        }
        guard let identityTokenData = appleIDCredential.identityToken else {
            continuation?.resume(returning: .failure(.missingIdentityToken))
            return
        }
        guard let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            continuation?.resume(returning: .failure(.invalidTokenFormat))
            return
        }
        guard let rawNonce else {
            continuation?.resume(returning: .failure(.missingNonce))
            return
        }

        let result = AppleSignInResult(
            identityToken: identityToken,
            rawNonce: rawNonce,
            fullName: appleIDCredential.fullName,
            email: appleIDCredential.email
        )
        continuation?.resume(returning: .success(result))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        defer {
            continuation = nil
            rawNonce = nil
        }

        if let asError = error as? ASAuthorizationError, asError.code == .canceled {
            continuation?.resume(returning: .failure(.userCancelled))
        } else {
            continuation?.resume(returning: .failure(.unexpected(error)))
        }
    }
}

extension AppleSignInProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        return scene?.keyWindow ?? ASPresentationAnchor()
    }
}

enum AppleSignInError: LocalizedError {
    case userCancelled
    case unexpectedCredentialType
    case missingIdentityToken
    case invalidTokenFormat
    case missingNonce
    case unexpected(any Error)

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            "사용자가 Apple 로그인 과정을 취소했습니다."
        case .unexpectedCredentialType:
            "Apple 로그인 과정에서 예상치 못한 credential 타입이 반환되었습니다."
        case .missingIdentityToken:
            "Apple 로그인 과정에서 identity token이 누락되었습니다."
        case .invalidTokenFormat:
            "Apple 로그인 과정에서 identity token의 형식이 올바르지 않습니다."
        case .missingNonce:
            "Apple 로그인 과정에서 nonce가 보관되어 있지 않습니다."
        case let .unexpected(error):
            "예상치 못한 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
