import Foundation

public enum AnalyticsEvent: Sendable, Equatable {
    case cryAnalysisStarted
    case cryAnalysisResultViewed(emotion: EmotionType)
    case careRecordSaved(category: CareEvent.Category)
    case noteCreated(noteID: UUID)
    case noteUpdated(noteID: UUID)
    case caregiverInviteStarted
    case caregiverInviteCompleted
    case statisticViewed(period: StatisticPeriod)
    case statisticPDFExported
}
