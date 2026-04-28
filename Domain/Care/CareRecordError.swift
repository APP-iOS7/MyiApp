import Foundation

public enum CareRecordError: Error, Sendable {
    case unauthorized
    case notFound
    case unexpected
}
