import Foundation

public struct AnalyticsClient: Sendable {
    public var track: @Sendable (AnalyticsEvent) -> Void
    public var trackScreen: @Sendable (ScreenName) -> Void
    public var setUserID: @Sendable (String?) -> Void
    public var setUserProperty: @Sendable (UserProperty) -> Void

    public init(
        track: @escaping @Sendable (AnalyticsEvent) -> Void,
        trackScreen: @escaping @Sendable (ScreenName) -> Void,
        setUserID: @escaping @Sendable (String?) -> Void,
        setUserProperty: @escaping @Sendable (UserProperty) -> Void
    ) {
        self.track = track
        self.trackScreen = trackScreen
        self.setUserID = setUserID
        self.setUserProperty = setUserProperty
    }
}
