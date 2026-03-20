import Foundation

public protocol RegisterCaregiverUseCaseProtocol: Sendable {
    func execute(_ caregiver: Caregiver) async throws
}

public struct RegisterCaregiverUseCase: RegisterCaregiverUseCaseProtocol {
    private let client: CaregiverClient

    public init(client: CaregiverClient) {
        self.client = client
    }

    public func execute(_ caregiver: Caregiver) async throws {
        // 비즈니스 로직: 이름이 비어있으면 안 됨
        guard !caregiver.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CaregiverError.invalidInteraction
        }

        try await self.client.registerCaregiver(caregiver)
    }
}
