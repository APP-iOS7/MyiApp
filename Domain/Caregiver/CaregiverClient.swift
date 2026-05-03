import Foundation

public struct CaregiverClient: Sendable {
    public var currentCaregiver: @Sendable () async throws(CaregiverError) -> Caregiver?
    public var streamCaregiver: @Sendable () -> AsyncStream<Caregiver?>
    public var streamCaregivers: @Sendable ([Caregiver.ID]) -> AsyncStream<[Caregiver]>
    public var provisionCaregiver: @Sendable () async throws(CaregiverError) -> Void
    public var updateDisplayName: @Sendable (String) async throws(CaregiverError) -> Void

    public init(
        currentCaregiver: @escaping @Sendable () async throws(CaregiverError) -> Caregiver?,
        streamCaregiver: @escaping @Sendable () -> AsyncStream<Caregiver?>,
        streamCaregivers: @escaping @Sendable ([Caregiver.ID]) -> AsyncStream<[Caregiver]>,
        provisionCaregiver: @escaping @Sendable () async throws(CaregiverError) -> Void,
        updateDisplayName: @escaping @Sendable (String) async throws(CaregiverError) -> Void
    ) {
        self.currentCaregiver = currentCaregiver
        self.streamCaregiver = streamCaregiver
        self.streamCaregivers = streamCaregivers
        self.provisionCaregiver = provisionCaregiver
        self.updateDisplayName = updateDisplayName
    }
}
