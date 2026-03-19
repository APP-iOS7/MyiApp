import XCTest
@testable import Domain

final class CaregiverErrorTests: XCTestCase {
    func test_errorDescription_returnsCorrectMessage_forEachCase() {
        XCTAssertEqual(CaregiverError.notFound.localizedDescription, "정보를 찾을 수 없습니다.")
        XCTAssertEqual(CaregiverError.unauthorized.localizedDescription, "권한이 없습니다.")
        XCTAssertEqual(CaregiverError.alreadyExists.localizedDescription, "이미 등록된 정보입니다.")
        XCTAssertEqual(CaregiverError.invalidInteraction.localizedDescription, "잘못된 요청입니다.")

        let underlyingError = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "테스트 에러"]
        )
        XCTAssertTrue(CaregiverError.internalError(underlyingError).localizedDescription
            .contains("테스트 에러"))
    }
}
