import Foundation
import Testing
@testable import Domain

struct BabyTests {
    @Test("아기 정보 초기화 시 모든 데이터가 정상적으로 설정됨")
    func babyInitializationSetsAllDataCorrectly() {
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
        #expect(baby.id == "baby-1")
        #expect(baby.name == "햇님이")
        #expect(baby.birthDate == birthDate)
        #expect(baby.gender == .male)
        #expect(baby.bloodType == .A)
        #expect(baby.imageURL?.absoluteString == "https://example.com/baby.jpg")
    }

    @Test("선택적 필드가 없을 때 nil로 설정됨")
    func optionalFieldsAreNilWhenNotProvided() {
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
        #expect(baby.bloodType == nil)
        #expect(baby.imageURL == nil)
    }
}
