import Testing
@testable import Domain

struct CaregiverTests {
    @Test("보호자 정보 초기화 시 모든 데이터가 정상적으로 설정됨")
    func caregiverInitializationSetsAllDataCorrectly() {
        // Given & When
        let caregiver = Caregiver(
            id: "caregiver-1",
            name: "보호자",
            email: "parent@example.com",
            role: "엄마",
            lastSelectedBabyID: "baby-1"
        )

        // Then
        #expect(caregiver.id == "caregiver-1")
        #expect(caregiver.name == "보호자")
        #expect(caregiver.email == "parent@example.com")
        #expect(caregiver.role == "엄마")
        #expect(caregiver.lastSelectedBabyID == "baby-1")
    }

    @Test("선택적 데이터가 없을 때 nil로 설정됨")
    func optionalDataIsNilWhenNotProvided() {
        // Given & When
        let caregiver = Caregiver(
            id: "caregiver-2",
            name: "아빠",
            email: "father@example.com"
        )

        // Then
        #expect(caregiver.role == nil)
        #expect(caregiver.lastSelectedBabyID == nil)
    }
}
