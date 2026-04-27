import ComposableArchitecture
import Domain

extension BabyClient: @retroactive TestDependencyKey {}
extension BabyClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        registerNewBaby: { @Sendable _, _ async throws(BabyError) -> Void in
            throw BabyError.unexpected
        },
        registerExistingBaby: { @Sendable _ async throws(BabyError) -> Void in
            throw BabyError.unexpected
        }
    )
}

public extension DependencyValues {
    var babyClient: BabyClient {
        get { self[BabyClient.self] }
        set { self[BabyClient.self] = newValue }
    }
}
