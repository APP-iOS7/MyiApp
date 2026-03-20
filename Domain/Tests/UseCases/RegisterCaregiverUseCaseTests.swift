import DomainTesting
import Foundation
import Testing
@testable import Domain

@MainActor
struct RegisterCaregiverUseCaseTests {
    @Test("올바른 보호자 정보로 등록 시 성공")
    func registerCaregiverSuccessWithValidInfo() async throws {
        // Given
        actor State {
            var isCalled = false
            func setCalled() {
                self.isCalled = true
            }
        }
        let state = State()

        let mockClient = CaregiverClient(
            fetchCaregiver: { _ throws(CaregiverError) in .mock },
            registerCaregiver: { _ throws(CaregiverError) in await state.setCalled() },
            connectCaregiver: { _, _ throws(CaregiverError) in }
        )
        let useCase = RegisterCaregiverUseCase(client: mockClient)
        let caregiver = Caregiver.mock

        // When
        try await useCase.execute(caregiver)

        // Then
        let isCalled = await state.isCalled
        #expect(isCalled == true)
    }

    @Test("이름이 비어있는 보호자 등록 시 에러 발생", arguments: ["", "  ", "\n"])
    func registerCaregiverFailsWithEmptyName(name: String) async throws {
        // Given
        let mockClient = CaregiverClient.mock
        let useCase = RegisterCaregiverUseCase(client: mockClient)
        let invalidCaregiver = Caregiver(id: "1", name: name, email: "test@test.com")

        // When / Then
        await #expect(throws: CaregiverError.invalidInteraction) {
            try await useCase.execute(invalidCaregiver)
        }
    }
}
