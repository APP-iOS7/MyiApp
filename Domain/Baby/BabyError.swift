import Foundation

public enum BabyError: Error, Sendable {
    case unauthorized
    case invalidInviteCode
    case unexpected
}
