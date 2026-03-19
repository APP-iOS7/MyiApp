import XCTest
@testable import Domain

final class CaregiverTests: XCTestCase {
    func test_Given_보호자정보가있을때_When_초기화하면_Then_모든데이터가정상적으로설정됨() {
        // Given & When
        let caregiver = Caregiver(
            id: "caregiver-1",
            name: "보호자",
            email: "parent@example.com",
            role: "엄마",
            lastSelectedBabyID: "baby-1"
        )

        // Then
        XCTAssertEqual(caregiver.id, "caregiver-1")
        XCTAssertEqual(caregiver.name, "보호자")
        XCTAssertEqual(caregiver.email, "parent@example.com")
        XCTAssertEqual(caregiver.role, "엄마")
        XCTAssertEqual(caregiver.lastSelectedBabyID, "baby-1")
    }

    func test_Given_선택적데이터가없을때_When_초기화하면_Then_해당필드가nil로설정됨() {
        // Given & When
        let caregiver = Caregiver(
            id: "caregiver-2",
            name: "아빠",
            email: "father@example.com"
        )

        // Then
        XCTAssertNil(caregiver.role)
        XCTAssertNil(caregiver.lastSelectedBabyID)
    }
}
