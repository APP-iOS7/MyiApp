import ComposableArchitecture
import Domain
import FirebaseAnalytics
import Foundation

extension AnalyticsClient: @retroactive DependencyKey {
    public static let liveValue: AnalyticsClient = .init(
        track: { event in
            let (name, params) = mapEvent(event)
            Analytics.logEvent(name, parameters: params)
        },
        trackScreen: { screen in
            Analytics.logEvent(
                AnalyticsEventScreenView,
                parameters: [
                    AnalyticsParameterScreenName: screen.rawValue,
                    AnalyticsParameterScreenClass: screen.rawValue
                ]
            )
        },
        setUserID: { uid in
            Analytics.setUserID(uid)
        },
        setUserProperty: { property in
            let (name, value) = mapProperty(property)
            Analytics.setUserProperty(value, forName: name)
        }
    )
}

extension DependencyValues {
    public var analytics: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}

private func mapEvent(_ event: AnalyticsEvent) -> (String, [String: Any]?) {
    switch event {
    case .cryAnalysisStarted:
        ("cry_analysis_started", nil)
    case let .cryAnalysisResultViewed(emotion):
        ("cry_analysis_result_viewed", ["emotion": emotion.rawValue])
    case let .careRecordSaved(category):
        ("care_record_saved", ["category": category.rawValue])
    case let .noteCreated(noteID):
        ("note_created", ["note_id": noteID.uuidString])
    case let .noteUpdated(noteID):
        ("note_updated", ["note_id": noteID.uuidString])
    case .caregiverInviteStarted:
        ("caregiver_invite_started", nil)
    case .caregiverInviteCompleted:
        ("caregiver_invite_completed", nil)
    case let .statisticViewed(period):
        ("statistic_viewed", ["period": period.rawValue])
    case .statisticPDFExported:
        ("statistic_pdf_exported", nil)
    }
}

private func mapProperty(_ property: UserProperty) -> (String, String?) {
    switch property {
    case let .babyCount(count):
        ("baby_count", String(count))
    case let .hasCaregiver(flag):
        ("has_caregiver", flag ? "true" : "false")
    case let .babyAgeMonthsBucket(bucket):
        ("baby_age_months", bucket.rawValue)
    case let .authProvider(provider):
        ("auth_provider", provider.rawValue)
    }
}
