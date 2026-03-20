import Foundation

public struct CaregiverClient: Sendable {
    public var fetchCaregiver: @Sendable (String) async throws(CaregiverError) -> Caregiver
    public var registerCaregiver: @Sendable (Caregiver) async throws(CaregiverError) -> Void
    public var connectCaregiver: @Sendable (String, String) async throws(CaregiverError) -> Void

    public init(
        fetchCaregiver: @escaping @Sendable (String) async throws(CaregiverError) -> Caregiver,
        registerCaregiver: @escaping @Sendable (Caregiver) async throws(CaregiverError) -> Void,
        connectCaregiver: @escaping @Sendable (String, String) async throws(CaregiverError) -> Void
    ) {
        self.fetchCaregiver = fetchCaregiver
        self.registerCaregiver = registerCaregiver
        self.connectCaregiver = connectCaregiver
    }
}
