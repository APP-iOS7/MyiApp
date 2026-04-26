import Foundation

final class AppleSignInProvider {
    func signIn() async throws(AppleSignInError) -> AppleSignInResult {
        fatalError("Not implemented yet")
    }
}

enum AppleSignInError: LocalizedError {
    case userCancelled
    case missingIdentityToken
    case invalidTokenFormat
    case unexpected(any Error)

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            "사용자가 Apple 로그인 과정을 취소했습니다."
        case .missingIdentityToken:
            "Apple 로그인 과정에서 identity token이 누락되었습니다."
        case .invalidTokenFormat:
            "Apple 로그인 과정에서 identity token의 형식이 올바르지 않습니다."
        case let .unexpected(error):
            "예상치 못한 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
