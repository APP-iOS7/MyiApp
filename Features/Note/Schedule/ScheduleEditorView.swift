import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct ScheduleEditorView: View {
    @Bindable var store: StoreOf<ScheduleEditorFeature>

    public init(store: StoreOf<ScheduleEditorFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("제목", text: $store.title)
                        .font(.title3.weight(.medium))
                    TextField("설명 (선택)", text: $store.description, axis: .vertical)
                        .lineLimit(2 ... 4)
                }

                Section("시각") {
                    DatePicker("시각", selection: $store.date, displayedComponents: [.hourAndMinute])
                }

                Section("미리 알림") {
                    reminderPresetChips
                    if case let .custom(value) = store.reminderMode {
                        DatePicker(
                            "알림 시각",
                            selection: Binding(
                                get: { value },
                                set: { store.send(.view(.customReminderChanged($0))) }
                            )
                        )
                    }
                }
            }
            .navigationTitle("일정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { store.send(.view(.cancelButtonTapped)) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { store.send(.view(.saveButtonTapped)) }
                        .disabled(!store.canSave)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private var reminderPresetChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(ReminderMode.presets, id: \.label) { preset in
                    SelectableChip(
                        label: preset.label,
                        isSelected: store.reminderMode == preset.mode
                    ) {
                        store.send(.view(.reminderPresetSelected(preset.mode)))
                    }
                }
                SelectableChip(
                    label: "직접 설정",
                    isSelected: store.isCustomReminder
                ) {
                    store.send(.view(.customReminderSelected))
                }
            }
        }
    }
}

#Preview {
    ScheduleEditorView(
        store: Store(initialState: ScheduleEditorFeature.State(babyID: UUID(), date: Date())) {
            ScheduleEditorFeature()
        }
    )
}
