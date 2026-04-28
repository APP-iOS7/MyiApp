import Foundation

public enum CryAnalysisError: Error, Sendable {
    case permissionDenied
    case recordingFailed
    case unauthorized
    case unexpected
}
