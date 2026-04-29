#if DEBUG
    import ConcurrencyExtras
    import Domain
    import Foundation

    extension NoteClient {
        public static var previewValue: Self {
            let store = LockIsolated<[Note]>(Note.previewSamples)
            return Self(
                loadNotes: { @Sendable _, range async throws(NoteError) -> [Note] in
                    store.value.filter { range.contains($0.date) }
                },
                addNote: { @Sendable _, note async throws(NoteError) in
                    store.withValue { $0.insert(note, at: 0) }
                },
                updateNote: { @Sendable _, note async throws(NoteError) in
                    store.withValue { notes in
                        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }

                        notes[index] = note
                    }
                },
                deleteNote: { @Sendable _, noteID async throws(NoteError) in
                    store.withValue { $0.removeAll { $0.id == noteID } }
                }
            )
        }
    }

    extension Note {
        fileprivate static var previewSamples: [Note] {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let nextWeek = calendar.date(byAdding: .day, value: 5, to: today)!

            func at(_ day: Date, hour: Int, minute: Int) -> Date {
                calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
            }

            let dummyImage = URL(string: "https://picsum.photos/200")!

            return [
                Note(
                    kind: .diary,
                    title: "처음 뒤집기 성공! 🎉",
                    description: "오후 낮잠 후에 갑자기 뒤집어서 깜짝 놀랐다.",
                    date: at(today, hour: 14, minute: 30),
                    imageURLs: [dummyImage]
                ),
                Note(
                    kind: .schedule,
                    title: "소아과 예약",
                    description: "예방접종 + 정기 검진",
                    date: at(today, hour: 18, minute: 0),
                    reminder: Reminder(scheduledAt: at(today, hour: 17, minute: 50))
                ),
                Note(
                    kind: .diary,
                    title: "이유식 시작",
                    description: "쌀미음 5g — 잘 받아먹음",
                    date: at(yesterday, hour: 12, minute: 30),
                    imageURLs: [dummyImage]
                ),
                Note(
                    kind: .schedule,
                    title: "예방접종 D-day",
                    description: "6개월 차 4종",
                    date: at(nextWeek, hour: 10, minute: 0),
                    reminder: Reminder(scheduledAt: at(nextWeek, hour: 9, minute: 0))
                )
            ]
        }
    }
#endif
