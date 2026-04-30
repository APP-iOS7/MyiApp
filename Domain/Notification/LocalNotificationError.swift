import Foundation

public enum LocalNotificationError: Error, Sendable {
    case permissionDenied
    case scheduledInPast
    case schedulingFailed
}
