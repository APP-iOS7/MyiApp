import Foundation

public enum StorageError: Error, Sendable {
    case unauthorized
    case quotaExceeded
    case objectNotFound
    case unexpected
}
