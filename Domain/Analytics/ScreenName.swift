import Foundation

public enum ScreenName: String, Sendable, Equatable {
    case home
    case cryAnalysisHome = "cry_analysis_home"
    case cryAnalysisRunning = "cry_analysis_running"
    case cryAnalysisResult = "cry_analysis_result"
    case noteList = "note_list"
    case noteEditor = "note_editor"
    case babyRegister = "baby_register"
    case caregiverInvite = "caregiver_invite"
    case statistic
    case settings
    case login
}
