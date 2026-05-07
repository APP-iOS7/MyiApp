import ComposableArchitecture
import Domain

extension AnalyticsClient: @retroactive TestDependencyKey {
    public static let testValue: AnalyticsClient = .init(
        track: { _ in },
        trackScreen: { _ in },
        setUserID: { _ in },
        setUserProperty: { _ in }
    )

    public static let previewValue: AnalyticsClient = testValue
}
