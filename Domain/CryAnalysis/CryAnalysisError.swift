import Foundation

public enum CryAnalysisError: Error, Sendable {
    case audioFileUnreadable
    case modelInferenceFailed
}
