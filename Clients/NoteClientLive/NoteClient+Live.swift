import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

extension NoteClient: @retroactive TestDependencyKey {}
extension NoteClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        streamNotes: { @Sendable babyID, range in
            AsyncStream { continuation in
                guard Auth.auth().currentUser?.uid != nil else {
                    continuation.finish()
                    return
                }
                let listener = notesCollection(babyID: babyID)
                    .whereField("date", isGreaterThanOrEqualTo: range.lowerBound)
                    .whereField("date", isLessThan: range.upperBound)
                    .order(by: "date", descending: true)
                    .addSnapshotListener { snapshot, _ in
                        guard let snapshot else { return }
                        let decoder = Firestore.Decoder()
                        let notes = snapshot.documents.compactMap { doc -> Note? in
                            try? decoder.decode(Note.self, from: doc.data())
                        }
                        continuation.yield(notes)
                    }
                continuation.onTermination = { _ in
                    listener.remove()
                }
            }
        },
        streamFutureScheduleNotes: { @Sendable babyID in
            AsyncStream { continuation in
                guard Auth.auth().currentUser?.uid != nil else {
                    continuation.finish()
                    return
                }
                let listener = notesCollection(babyID: babyID)
                    .whereField("kind", isEqualTo: NoteKind.schedule.rawValue)
                    .whereField("date", isGreaterThanOrEqualTo: Date())
                    .order(by: "date", descending: false)
                    .addSnapshotListener { snapshot, _ in
                        guard let snapshot else { return }
                        let decoder = Firestore.Decoder()
                        let notes = snapshot.documents.compactMap { doc -> Note? in
                            try? decoder.decode(Note.self, from: doc.data())
                        }
                        continuation.yield(notes)
                    }
                continuation.onTermination = { _ in
                    listener.remove()
                }
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
