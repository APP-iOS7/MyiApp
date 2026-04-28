import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct EditRecordView: View {
    @Bindable var store: StoreOf<EditRecordFeature>

    public init(store: StoreOf<EditRecordFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                eventSection

                if !isSleep {
                    Section("기록 시각") {
                        DatePicker("기록 시각", selection: $store.createdAt)
                    }
                }

                Section("메모") {
                    TextField("메모 (선택)", text: $store.content)
                }

                Section {
                    Button("기록 삭제", role: .destructive) {
                        store.send(.deleteTapped)
                    }
                    .disabled(store.isSubmitting)
                }
            }
            .navigationTitle(store.originalEvent.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { store.send(.cancelTapped) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { store.send(.saveTapped) }
                        .disabled(store.isSubmitting)
                }
            }
        }
    }

    private var isSleep: Bool {
        if case .sleep = store.originalEvent { return true }
        return false
    }

    @ViewBuilder
    private var eventSection: some View {
        switch store.originalEvent {
        case .sleep:
            Section("수면 시간") {
                DatePicker(
                    "시작",
                    selection: $store.sleepStart,
                    in: ...(store.sleepEnd ?? .distantFuture)
                )
                if let end = store.sleepEnd {
                    DatePicker(
                        "종료",
                        selection: Binding(
                            get: { end },
                            set: { store.sleepEnd = $0 }
                        ),
                        in: store.sleepStart...
                    )
                } else {
                    HStack {
                        Text("종료")
                        Spacer()
                        Button("현재 시간 기록") { store.send(.markSleepEndNow) }
                            .buttonStyle(.bordered)
                    }
                }
            }

        case .pee, .poop, .pottyAll:
            Section("종류") {
                Picker("종류", selection: $store.pottyKind) {
                    Text("소변").tag(EditRecordFeature.PottyKind.pee)
                    Text("대변").tag(EditRecordFeature.PottyKind.poop)
                    Text("둘다").tag(EditRecordFeature.PottyKind.both)
                }
                .pickerStyle(.segmented)
            }

        case .medicine, .clinic:
            Section("종류") {
                Picker("종류", selection: $store.medicalKind) {
                    Text("투약").tag(EditRecordFeature.MedicalKind.medicine)
                    Text("병원").tag(EditRecordFeature.MedicalKind.clinic)
                }
                .pickerStyle(.segmented)
            }

        case .bath, .snack:
            EmptyView()

        default:
            Section {
                Text("이 카테고리 편집은 준비 중")
                    .foregroundColor(.Semantic.secondaryText)
            }
        }
    }
}
