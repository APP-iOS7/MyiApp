import XCTest

@testable import Domain

final class AuthErrorTests: XCTestCase {
    func test_errorDescription_returnsCorrectMessage_forEachCase() {
        XCTAssertEqual(AuthError.cancelled.errorDescription, "로그인이 취소되었습니다.")
        XCTAssertEqual(AuthError.invalidCredentials.errorDescription, "인증에 실패했습니다.")
        XCTAssertEqual(AuthError.networkUnavailable.errorDescription, "네트워크 연결을 확인해 주세요.")
        XCTAssertEqual(AuthError.sessionExpired.errorDescription, "세션이 만료되었습니다. 다시 로그인해 주세요.")
        XCTAssertEqual(AuthError.unknown.errorDescription, "오류가 발생했습니다.")
    }
}
