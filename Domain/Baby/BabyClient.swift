import Foundation

public struct BabyClient: Sendable {
    public var currentBabies: @Sendable () async throws(BabyError) -> [Baby]
    public var registerNewBaby: @Sendable (Baby, GrowthRecord) async throws(BabyError) -> Void
    public var registerExistingBaby: @Sendable (UUID) async throws(BabyError) -> Void

    public init(
        currentBabies: @escaping @Sendable () async throws(BabyError) -> [Baby],
        registerNewBaby: @escaping @Sendable (Baby, GrowthRecord) async throws(BabyError) -> Void,
        registerExistingBaby: @escaping @Sendable (UUID) async throws(BabyError) -> Void
    ) {
        self.currentBabies = currentBabies
        self.registerNewBaby = registerNewBaby
        self.registerExistingBaby = registerExistingBaby
    }
}
