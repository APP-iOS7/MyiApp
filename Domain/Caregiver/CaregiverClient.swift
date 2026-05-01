import Foundation

public struct CaregiverClient: Sendable {
    public var currentCaregiver: @Sendable () async throws(CaregiverError) -> Caregiver?
    public var streamCaregiver: @Sendable () -> AsyncStream<Caregiver?>
    public var provisionCaregiver: @Sendable (Caregiver) async throws(CaregiverError) -> Void
    public var updateDisplayName: @Sendable (String) async throws(CaregiverError) -> Void

    public init(
        currentCaregiver: @escaping @Sendable () async throws(CaregiverError) -> Caregiver?,
        streamCaregiver: @escaping @Sendable () -> AsyncStream<Caregiver?>,
        provisionCaregiver: @escaping @Sendable (Caregiver) async throws(CaregiverError) -> Void,
        updateDisplayName: @escaping @Sendable (String) async throws(CaregiverError) -> Void
    ) {
        self.currentCaregiver = currentCaregiver
        self.streamCaregiver = streamCaregiver
        self.provisionCaregiver = provisionCaregiver
        self.updateDisplayName = updateDisplayName
    }
}
