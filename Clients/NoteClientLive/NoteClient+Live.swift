import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

extension NoteClient: @retroactive TestDependencyKey {}
extension NoteClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        loadNotes: { @Sendable babyID, range async throws(NoteError) -> [Note] in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                let snapshot = try await notesCollection(babyID: babyID)
                    .whereField("date", isGreaterThanOrEqualTo: range.lowerBound)
                    .whereField("date", isLessThan: range.upperBound)
                    .order(by: "date", descending: true)
                    .getDocuments()
                let decoder = Firestore.Decoder()
                return try snapshot.documents.map { doc in
                    try decoder.decode(Note.self, from: doc.data())
                }
            } catch {
                throw .unexpected
            }
        },
        addNote: { @Sendable babyID, note async throws(NoteError) -> Void in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                let data = try Firestore.Encoder().encode(note)
                try await notesCollection(babyID: babyID)
                    .document(note.id.uuidString)
                    .setData(data)
            } catch {
                throw .unexpected
            }
        },
        updateNote: { @Sendable babyID, note async throws(NoteError) -> Void in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                let data = try Firestore.Encoder().encode(note)
                try await notesCollection(babyID: babyID)
                    .document(note.id.uuidString)
                    .setData(data, merge: true)
            } catch {
                throw .unexpected
            }
        },
        deleteNote: { @Sendable babyID, noteID async throws(NoteError) -> Void in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                try await notesCollection(babyID: babyID)
                    .document(noteID.uuidString)
                    .delete()
            } catch {
                throw .unexpected
            }
        }
    )
}

public extension DependencyValues {
    var noteClient: NoteClient {
        get { self[NoteClient.self] }
        set { self[NoteClient.self] = newValue }
    }
}

private func notesCollection(babyID: UUID) -> CollectionReference {
    Firestore.firestore()
        .collection("babies")
        .document(babyID.uuidString)
        .collection("notes")
}
