import XCTest
@testable import Domain

final class CaregiverTests: XCTestCase {
    func test_init_setsPropertiesCorrectly() {
        let caregiver = Caregiver(
            id: "caregiver-1",
            name: "보호자",
            email: "parent@example.com",
            role: "엄마",
            lastSelectedBabyID: "baby-1"
        )

        XCTAssertEqual(caregiver.id, "caregiver-1")
        XCTAssertEqual(caregiver.name, "보호자")
        XCTAssertEqual(caregiver.email, "parent@example.com")
        XCTAssertEqual(caregiver.role, "엄마")
        XCTAssertEqual(caregiver.lastSelectedBabyID, "baby-1")
    }

    func test_init_withOptionalProperties_setsNilCorrectly() {
        let caregiver = Caregiver(
            id: "caregiver-2",
            name: "아빠",
            email: "father@example.com"
        )

        XCTAssertNil(caregiver.role)
        XCTAssertNil(caregiver.lastSelectedBabyID)
    }
}
