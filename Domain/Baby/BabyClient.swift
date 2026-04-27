import Foundation

public struct BabyClient: Sendable {
    public var registerNewBaby: @Sendable (Baby, GrowthRecord) async throws(BabyError) -> Void
    public var registerExistingBaby: @Sendable (String) async throws(BabyError) -> Void

    public init(
        registerNewBaby: @escaping @Sendable (Baby, GrowthRecord) async throws(BabyError) -> Void,
        registerExistingBaby: @escaping @Sendable (String) async throws(BabyError) -> Void
    ) {
        self.registerNewBaby = registerNewBaby
        self.registerExistingBaby = registerExistingBaby
    }
}
