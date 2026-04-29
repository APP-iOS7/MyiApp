import Foundation

public enum CryRecordError: Error, Sendable {
    case unauthorized
    case notFound
    case unexpected
}
