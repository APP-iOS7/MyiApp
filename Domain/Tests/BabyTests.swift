import XCTest

@testable import Domain

final class BabyTests: XCTestCase {
    func test_Given_아기정보가있을때_When_초기화하면_Then_모든데이터가정상적으로설정됨() {
        // Given
        let birthDate = Date()

        // When
        let baby = Baby(
            id: "baby-1",
            name: "햇님이",
            birthDate: birthDate,
            gender: .male,
            bloodType: .A,
            imageURL: URL(string: "https://example.com/baby.jpg")
        )

        // Then
        XCTAssertEqual(baby.id, "baby-1")
        XCTAssertEqual(baby.name, "햇님이")
        XCTAssertEqual(baby.birthDate, birthDate)
        XCTAssertEqual(baby.gender, .male)
        XCTAssertEqual(baby.bloodType, .A)
        XCTAssertEqual(baby.imageURL?.absoluteString, "https://example.com/baby.jpg")
    }

    func test_Given_혈액형이미지가없을때_When_초기화하면_Then_해당필드가nil로설정됨() {
        // Given
        let birthDate = Date()

        // When
        let baby = Baby(
            id: "baby-2",
            name: "달님이",
            birthDate: birthDate,
            gender: .female
        )

        // Then
        XCTAssertNil(baby.bloodType)
        XCTAssertNil(baby.imageURL)
    }
}
