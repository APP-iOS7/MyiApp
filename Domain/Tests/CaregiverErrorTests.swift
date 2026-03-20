import Foundation
import Testing
@testable import Domain

struct CaregiverErrorTests {
    @Test("케어기버 에러 메시지 한국어 반환 확인")
    func caregiverErrorMessageReturnsKorean() {
        #expect(CaregiverError.notFound.localizedDescription == "정보를 찾을 수 없습니다.")
        #expect(CaregiverError.unauthorized.localizedDescription == "권한이 없습니다.")
        #expect(CaregiverError.alreadyExists.localizedDescription == "이미 등록된 정보입니다.")
        #expect(CaregiverError.invalidInteraction.localizedDescription == "잘못된 요청입니다.")

        // Given
        let underlyingError = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "테스트 에러"]
        )

        // When
        let error = CaregiverError.internalError(underlyingError)

        // Then
        #expect(error.localizedDescription.contains("테스트 에러"))
    }
}
