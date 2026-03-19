import XCTest
@testable import Domain

final class BabyTests: XCTestCase {
    func test_init_setsPropertiesCorrectly() {
        let birthDate = Date()
        let baby = Baby(
            id: "baby-1",
            name: "햇님이",
            birthDate: birthDate,
            gender: .male,
            bloodType: .A,
            imageURL: URL(string: "https://example.com/baby.jpg")
        )

        XCTAssertEqual(baby.id, "baby-1")
        XCTAssertEqual(baby.name, "햇님이")
        XCTAssertEqual(baby.birthDate, birthDate)
        XCTAssertEqual(baby.gender, .male)
        XCTAssertEqual(baby.bloodType, .A)
        XCTAssertEqual(baby.imageURL?.absoluteString, "https://example.com/baby.jpg")
    }

    func test_init_withOptionalProperties_setsNilCorrectly() {
        let birthDate = Date()
        let baby = Baby(
            id: "baby-2",
            name: "달님이",
            birthDate: birthDate,
            gender: .female
        )

        XCTAssertNil(baby.bloodType)
        XCTAssertNil(baby.imageURL)
    }
}
