import ComposableArchitecture
import Domain
import Foundation
import Shared

extension NoteClient: @retroactive TestDependencyKey {}
extension NoteClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        streamNotes: { @Sendable babyID, range in
            NoteStream.make(babyID: babyID, filter: .range(range))
        },
        streamFutureScheduleNotes: { @Sendable babyID in
            NoteStream.make(babyID: babyID, filter: .futureSchedules)
        },
        addNote: { @Sendable babyID, note async throws(NoteError) in
            do {
                let req = CreateNoteRequestDTO(
                    kind: note.kind,
                    title: note.title,
                    description: note.description,
                    date: note.date,
                    imageURLs: note.imageURLs.map(\.absoluteString),
                    reminder: note.reminder.map { CreateNoteRequestDTO.ReminderInput(scheduledAt: $0.scheduledAt) }
                )
                let _: NoteResponseDTO = try await APIClient.shared.postJSON(
                    "/babies/\(babyID.uuidString)/notes",
                    body: req
                )
            } catch let api as APIError {
                throw mapNoteError(api)
            } catch {
                throw .unexpected
            }
        },
        updateNote: { @Sendable babyID, note async throws(NoteError) in
            do {
                let req = UpdateNoteRequestDTO(
                    kind: note.kind,
                    title: note.title,
                    description: note.description,
                    date: note.date,
                    imageURLs: note.imageURLs.map(\.absoluteString),
                    reminder: note.reminder.map { CreateNoteRequestDTO.ReminderInput(scheduledAt: $0.scheduledAt) },
                    removeReminder: note.reminder == nil ? true : nil
                )
                let _: NoteResponseDTO = try await APIClient.shared.patch(
                    "/babies/\(babyID.uuidString)/notes/\(note.id.uuidString)",
                    body: req
                )
            } catch let api as APIError {
                throw mapNoteError(api)
            } catch {
                throw .unexpected
            }
        },
        deleteNote: { @Sendable babyID, noteID async throws(NoteError) in
            do {
                try await APIClient.shared.deleteEmpty(
                    "/babies/\(babyID.uuidString)/notes/\(noteID.uuidString)"
                )
            } catch let api as APIError {
                throw mapNoteError(api)
            } catch {
                throw .unexpected
            }
        }
    )
}

extension DependencyValues {
    public var noteClient: NoteClient {
        get { self[NoteClient.self] }
        set { self[NoteClient.self] = newValue }
    }
}

// MARK: - DTOs

struct NoteResponseDTO: Decodable, Sendable {
    let id: UUID
    let babyId: UUID
    let creatorId: String
    let kind: NoteKind
    let title: String
    let description: String
    let date: Date
    let imageURLs: [String]
    let reminder: ReminderDTO?
    let createdAt: Date

    struct ReminderDTO: Decodable, Sendable {
        let scheduledAt: Date
    }

    func toNote() -> Note {
        Note(
            id: id,
            creatorID: creatorId,
            kind: kind,
            title: title,
            description: description,
            date: date,
            imageURLs: imageURLs.compactMap(URL.init(string:)),
            reminder: reminder.map { Reminder(scheduledAt: $0.scheduledAt) },
            createdAt: createdAt
        )
    }
}

struct CreateNoteRequestDTO: Encodable, Sendable {
    let kind: NoteKind
    let title: String
    let description: String?
    let date: Date
    let imageURLs: [String]?
    let reminder: ReminderInput?

    struct ReminderInput: Encodable, Sendable {
        let scheduledAt: Date
    }
}

struct UpdateNoteRequestDTO: Encodable, Sendable {
    let kind: NoteKind?
    let title: String?
    let description: String?
    let date: Date?
    let imageURLs: [String]?
    let reminder: CreateNoteRequestDTO.ReminderInput?
    let removeReminder: Bool?
}

private func mapNoteError(_ error: APIError) -> NoteError {
    switch error {
    case .unauthorized: return .unauthorized
    case .forbidden:    return .unauthorized
    case .notFound:     return .notFound
    default:            return .unexpected
    }
}

// MARK: - SSE-driven stream

enum NoteStream {
    enum Filter {
        case range(Range<Date>)
        case futureSchedules
    }

    static func make(babyID: UUID, filter: Filter) -> AsyncStream<[Note]> {
        AsyncStream { continuation in
            let task = Task {
                guard AuthState.shared.snapshot() != nil else {
                    continuation.finish()
                    return
                }
                if let initial = try? await fetch(babyID: babyID, filter: filter) {
                    continuation.yield(initial)
                }
                let sse = SSEClient()
                let stream = sse.events(path: "/babies/\(babyID.uuidString)/stream")
                do {
                    for try await event in stream {
                        try Task.checkCancellation()
                        guard event.name == "update" else { continue }
                        if event.data.contains("\"note.") {
                            if let next = try? await fetch(babyID: babyID, filter: filter) {
                                continuation.yield(next)
                            }
                        }
                    }
                } catch {
                    AppLogger.debug("NoteStream sse ended: \(error)")
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func fetch(babyID: UUID, filter: Filter) async throws -> [Note] {
        var query: [String: String] = [:]
        if case let .range(range) = filter {
            query["from"] = ISO8601.fractional.string(from: range.lowerBound)
            query["to"]   = ISO8601.fractional.string(from: range.upperBound)
        }
        let dtos: [NoteResponseDTO] = try await APIClient.shared.get(
            "/babies/\(babyID.uuidString)/notes",
            query: query
        )
        let notes = dtos.map { $0.toNote() }
        switch filter {
        case .range:
            return notes
        case .futureSchedules:
            let now = Date()
            return notes
                .filter { $0.kind == .schedule && $0.date >= now }
                .sorted { $0.date < $1.date }
        }
    }
}
