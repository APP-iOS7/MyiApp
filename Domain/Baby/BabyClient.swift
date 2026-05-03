import Foundation

public struct BabyClient: Sendable {
    public var currentBabies: @Sendable () async throws(BabyError) -> [Baby]
    public var streamBabies: @Sendable () -> AsyncStream<[Baby]>
    public var streamBaby: @Sendable (UUID) -> AsyncStream<Baby>
    public var registerNewBaby: @Sendable (Baby) async throws(BabyError) -> Void
    public var registerExistingBaby: @Sendable (UUID) async throws(BabyError) -> Void
    public var updateBaby: @Sendable (Baby) async throws(BabyError) -> Void
    public var removeCaregiver: @Sendable (UUID, String) async throws(BabyError) -> Void

    public init(
        currentBabies: @escaping @Sendable () async throws(BabyError) -> [Baby],
        streamBabies: @escaping @Sendable () -> AsyncStream<[Baby]>,
        streamBaby: @escaping @Sendable (UUID) -> AsyncStream<Baby>,
        registerNewBaby: @escaping @Sendable (Baby) async throws(BabyError) -> Void,
        registerExistingBaby: @escaping @Sendable (UUID) async throws(BabyError) -> Void,
        updateBaby: @escaping @Sendable (Baby) async throws(BabyError) -> Void,
        removeCaregiver: @escaping @Sendable (UUID, String) async throws(BabyError) -> Void
    ) {
        self.currentBabies = currentBabies
        self.streamBabies = streamBabies
        self.streamBaby = streamBaby
        self.registerNewBaby = registerNewBaby
        self.registerExistingBaby = registerExistingBaby
        self.updateBaby = updateBaby
        self.removeCaregiver = removeCaregiver
    }
}
