import Foundation

public struct CaregiverClient: Sendable {
    public var currentCaregiver: @Sendable () async throws(CaregiverError) -> Caregiver?
    public var streamCaregiver: @Sendable () -> AsyncStream<Caregiver?>
    public var updateDisplayName: @Sendable (String) async throws(CaregiverError) -> Void

    public init(
        currentCaregiver: @escaping @Sendable () async throws(CaregiverError) -> Caregiver?,
        streamCaregiver: @escaping @Sendable () -> AsyncStream<Caregiver?>,
        updateDisplayName: @escaping @Sendable (String) async throws(CaregiverError) -> Void
    ) {
        self.currentCaregiver = currentCaregiver
        self.streamCaregiver = streamCaregiver
        self.updateDisplayName = updateDisplayName
    }
}
