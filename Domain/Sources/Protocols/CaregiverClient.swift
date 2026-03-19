import Foundation

public struct CaregiverClient: Sendable {
    public var fetchCaregiver: @Sendable (String) async throws -> Caregiver
    public var registerCaregiver: @Sendable (Caregiver) async throws -> Void
    public var connectCaregiver: @Sendable (String, String) async throws -> Void

    public init(
        fetchCaregiver: @escaping @Sendable (String) async throws -> Caregiver,
        registerCaregiver: @escaping @Sendable (Caregiver) async throws -> Void,
        connectCaregiver: @escaping @Sendable (String, String) async throws -> Void
    ) {
        self.fetchCaregiver = fetchCaregiver
        self.registerCaregiver = registerCaregiver
        self.connectCaregiver = connectCaregiver
    }
}
