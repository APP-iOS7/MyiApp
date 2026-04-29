import DesignSystem
import Domain
import SwiftUI

public struct NoteView: View {
    public let baby: Baby?

    @State private var month: Date = Date()
    @State private var selected: Date = Date()

    public init(baby: Baby?) {
        self.baby = baby
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                ScreenTitle("육아 수첩")

                SectionCard(spacing: Spacing.s) {
                    CalendarHeader(month: $month, selected: $selected)
                    CalendarGrid(
                        month: month,
                        selected: selected,
                        datesWithIndicator: Set(sampleNotes.map { Calendar.current.startOfDay(for: $0.date) }),
                        onSelect: { selected = $0 }
                    )
                }

                eventSection
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private var eventSection: some View {
        let notesOfDay = sampleNotes.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selected)
        }

        SectionCard(spacing: Spacing.m) {
            HStack {
                Text(selected, format: .dateTime.month(.wide).day().weekday(.wide))
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: IconSize.m))
                        .foregroundColor(.Semantic.primaryAction)
                }
                .buttonStyle(NoHighlightButtonStyle())
            }

            if notesOfDay.isEmpty {
                emptyState
            } else {
                VStack(spacing: Spacing.s) {
                    ForEach(notesOfDay) { note in
                        NoteEventRow(
                            title: note.title,
                            description: note.description,
                            date: note.date,
                            hasImage: note.hasImage,
                            hasReminder: note.hasReminder
                        )
                        if note.id != notesOfDay.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "doc.text")
                .font(.system(size: IconSize.l))
                .foregroundColor(.Semantic.secondaryText)
            Text("기록이 없어요")
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.l)
    }

    private var sampleNotes: [PreviewNote] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 5, to: today)!

        func at(_ day: Date, hour: Int, minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }

        return [
            PreviewNote(
                date: at(today, hour: 14, minute: 30),
                title: "처음 뒤집기 성공! 🎉",
                description: "오후 낮잠 후에 갑자기 뒤집어서 깜짝 놀랐다. 영상도 못 찍었네…",
                hasImage: true,
                hasReminder: false
            ),
            PreviewNote(
                date: at(today, hour: 18, minute: 0),
                title: "소아과 예약",
                description: "예방접종 + 정기 검진",
                hasImage: false,
                hasReminder: true
            ),
            PreviewNote(
                date: at(today, hour: 21, minute: 0),
                title: "수면 일지",
                description: "8시간 푹 잠. 새벽에 한 번만 깸.",
                hasImage: false,
                hasReminder: false
            ),
            PreviewNote(
                date: at(yesterday, hour: 12, minute: 30),
                title: "이유식 시작",
                description: "쌀미음 5g — 잘 받아먹음",
                hasImage: true,
                hasReminder: false
            ),
            PreviewNote(
                date: at(nextWeek, hour: 10, minute: 0),
                title: "예방접종 D-day",
                description: "6개월 차 4종",
                hasImage: false,
                hasReminder: true
            )
        ]
    }
}

private struct PreviewNote: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let description: String
    let hasImage: Bool
    let hasReminder: Bool
}

#Preview {
    NoteView(baby: nil)
}
