import GoogleSignIn
import UIKit

@MainActor
enum GoogleSignInProvider {
    static func signIn() async throws(GoogleSignInError) -> GoogleSignInResult {
        guard let presentingViewController = Self.topViewController() else {
            throw .missingPresentingViewController
        }

        do {
            return try await withCheckedThrowingContinuation { continuation in
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let result else {
                        continuation.resume(throwing: GoogleSignInError.unknown)
                        return
                    }
                    guard let idToken = result.user.idToken?.tokenString else {
                        continuation.resume(throwing: GoogleSignInError.missingIDToken)
                        return
                    }
                    continuation.resume(
                        returning: GoogleSignInResult(
                            idToken: idToken,
                            accessToken: result.user.accessToken.tokenString
                        )
                    )
                }
            }
        } catch {
            if let signInError = error as? GIDSignInError, signInError.code == .canceled {
                throw .userCancelled
            }
            if let mappedError = error as? GoogleSignInError {
                throw mappedError
            }
            throw .unexpected(error)
        }
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var current = scene?.keyWindow?.rootViewController
        while let presented = current?.presentedViewController {
            current = presented
        }
        return current
    }
}

enum GoogleSignInError: LocalizedError {
    case userCancelled
    case missingPresentingViewController
    case missingIDToken
    case unknown
    case unexpected(any Error)

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            "사용자가 Google 로그인 과정을 취소했습니다."
        case .missingPresentingViewController:
            "Google 로그인 UI를 표시할 ViewController를 찾을 수 없습니다."
        case .missingIDToken:
            "Google 로그인 과정에서 ID token이 누락되었습니다."
        case .unknown:
            "Google 로그인 과정에서 알 수 없는 결과가 반환되었습니다."
        case let .unexpected(error):
            "예상치 못한 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
