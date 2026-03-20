import Testing
@testable import Domain

struct AuthErrorTests {
    @Test("에러 메시지가 각 케이스별로 올바르게 반환되는지 확인")
    func errorMessageIsCorrectForEachCase() {
        #expect(AuthError.cancelled.errorDescription == "로그인이 취소되었습니다.")
        #expect(AuthError.invalidCredentials.errorDescription == "인증에 실패했습니다.")
        #expect(AuthError.networkUnavailable.errorDescription == "네트워크 연결을 확인해 주세요.")
        #expect(AuthError.sessionExpired.errorDescription == "세션이 만료되었습니다. 다시 로그인해 주세요.")
        #expect(AuthError.unknown.errorDescription == "오류가 발생했습니다.")
    }
}
