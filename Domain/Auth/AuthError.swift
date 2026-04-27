import Foundation

public enum AuthError: Error, Sendable {
    case requiresRecentLogin
    case unexpected
}
