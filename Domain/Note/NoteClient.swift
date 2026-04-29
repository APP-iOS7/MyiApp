import Foundation

public struct NoteClient: Sendable {
    public var loadNotes: @Sendable (UUID, Range<Date>) async throws(NoteError) -> [Note]
    public var addNote: @Sendable (UUID, Note) async throws(NoteError) -> Void
    public var updateNote: @Sendable (UUID, Note) async throws(NoteError) -> Void
    public var deleteNote: @Sendable (UUID, UUID) async throws(NoteError) -> Void

    public init(
        loadNotes: @escaping @Sendable (UUID, Range<Date>) async throws(NoteError) -> [Note],
        addNote: @escaping @Sendable (UUID, Note) async throws(NoteError) -> Void,
        updateNote: @escaping @Sendable (UUID, Note) async throws(NoteError) -> Void,
        deleteNote: @escaping @Sendable (UUID, UUID) async throws(NoteError) -> Void
    ) {
        self.loadNotes = loadNotes
        self.addNote = addNote
        self.updateNote = updateNote
        self.deleteNote = deleteNote
    }
}
