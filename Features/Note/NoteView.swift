import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct NoteView: View {
    @Bindable var store: StoreOf<NoteHomeFeature>

    public init(store: StoreOf<NoteHomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                ScreenTitle("육아 수첩")

                SectionCard(spacing: Spacing.s) {
                    CalendarHeader(month: $store.month, selected: $store.selected)
                    CalendarGrid(
                        month: store.month,
                        selected: $store.selected,
                        datesWithIndicator: store.datesWithIndicator
                    )
                }

                eventSection
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .task { await store.send(.task).finish() }
        .sheet(item: $store.sheet) { sheet in
            switch sheet {
            case let .diary(date):
                DiaryEditorView(initialDate: date) { note in
                    store.send(.noteSaved(note))
                }
            case let .schedule(date):
                ScheduleEditorView(initialDate: date) { note in
                    store.send(.noteSaved(note))
                }
            }
        }
    }

    private var eventSection: some View {
        SectionCard(spacing: Spacing.m) {
            HStack {
                Text(store.selected, format: .dateTime.month(.wide).day().weekday(.wide))
                    .font(.headline)
                Spacer()
                if !store.isFutureDay {
                    ActionChip(label: "일지", systemImage: "doc.text") {
                        store.send(.diaryButtonTapped)
                    }
                }
                if !store.isPastDay {
                    ActionChip(label: "일정", systemImage: "bell") {
                        store.send(.scheduleButtonTapped)
                    }
                }
            }

            if store.notesOfDay.isEmpty {
                EmptyNoteView()
            } else {
                VStack(spacing: Spacing.s) {
                    ForEach(store.notesOfDay) { note in
                        NoteEventRow(note: note)
                        if note.id != store.notesOfDay.last?.id { Divider() }
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        NoteView(
            store: Store(
                initialState: NoteHomeFeature.State(
                    baby: Baby(
                        name: "아기",
                        birthDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                        gender: .male,
                        bloodType: .a,
                        mainCaregiverID: "preview"
                    )
                )
            ) {
                NoteHomeFeature()
            }
        )
    }
#endif
