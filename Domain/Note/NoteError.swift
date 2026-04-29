import Foundation

public enum NoteError: Error, Sendable {
    case unauthorized
    case notFound
    case unexpected
}
