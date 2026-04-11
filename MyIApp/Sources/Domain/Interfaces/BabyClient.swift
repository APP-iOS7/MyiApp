import Foundation

public struct BabyClient: Sendable {
    public var registerNewBaby: @Sendable (NewBabyRequest) async throws -> Baby
    public var registerExistingBaby: @Sendable (String) async throws -> Baby
}
