import Foundation

public struct NoteClient: Sendable {
    public var streamNotes: @Sendable (UUID, Range<Date>) -> AsyncStream<[Note]>
    public var addNote: @Sendable (UUID, Note) async throws(NoteError) -> Void
    public var updateNote: @Sendable (UUID, Note) async throws(NoteError) -> Void
    public var deleteNote: @Sendable (UUID, UUID) async throws(NoteError) -> Void

    public init(
        streamNotes: @escaping @Sendable (UUID, Range<Date>) -> AsyncStream<[Note]>,
        addNote: @escaping @Sendable (UUID, Note) async throws(NoteError) -> Void,
        updateNote: @escaping @Sendable (UUID, Note) async throws(NoteError) -> Void,
        deleteNote: @escaping @Sendable (UUID, UUID) async throws(NoteError) -> Void
    ) {
        self.streamNotes = streamNotes
        self.addNote = addNote
        self.updateNote = updateNote
        self.deleteNote = deleteNote
    }
}
