import XCTest
@testable import Domain

final class CaregiverErrorTests: XCTestCase {
    func test_Given_케어기버에러가발생했을때_When_메시지를조회하면_Then_정의된한국어메시지가반환됨() {
        // Given & When & Then
        XCTAssertEqual(CaregiverError.notFound.localizedDescription, "정보를 찾을 수 없습니다.")
        XCTAssertEqual(CaregiverError.unauthorized.localizedDescription, "권한이 없습니다.")
        XCTAssertEqual(CaregiverError.alreadyExists.localizedDescription, "이미 등록된 정보입니다.")
        XCTAssertEqual(CaregiverError.invalidInteraction.localizedDescription, "잘못된 요청입니다.")

        // Given
        let underlyingError = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "테스트 에러"]
        )

        // When
        let error = CaregiverError.internalError(underlyingError)

        // Then
        XCTAssertTrue(error.localizedDescription.contains("테스트 에러"))
    }
}
