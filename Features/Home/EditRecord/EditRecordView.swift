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
                        store.send(.view(.deleteTapped))
                    }
                    .disabled(store.isSubmitting)
                }
            }
            .navigationTitle(store.originalEvent.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { store.send(.view(.cancelTapped)) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { store.send(.view(.saveTapped)) }
                        .disabled(store.isSubmitting)
                }
            }
        }
    }

    private var isSleep: Bool {
        if case .sleep = store.originalEvent { return true }
        return false
    }

    private var heightText: Binding<String> {
        Binding(
            get: { store.heightCm.map { String(format: "%.1f", $0) } ?? "" },
            set: { store.heightCm = Double($0) }
        )
    }

    private var weightText: Binding<String> {
        Binding(
            get: { store.weightKg.map { String(format: "%.2f", $0) } ?? "" },
            set: { store.weightKg = Double($0) }
        )
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
                        Button("현재 시간 기록") { store.send(.view(.markSleepEndNow)) }
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

        case .formula, .babyFood, .pumpedMilk, .breastfeeding:
            Section("종류") {
                Picker("종류", selection: $store.feedingKind) {
                    Text("분유").tag(EditRecordFeature.FeedingKind.formula)
                    Text("이유식").tag(EditRecordFeature.FeedingKind.babyFood)
                    Text("유축").tag(EditRecordFeature.FeedingKind.pumpedMilk)
                    Text("모유").tag(EditRecordFeature.FeedingKind.breastfeeding)
                }
                .pickerStyle(.segmented)
            }

            if store.feedingKind == .breastfeeding {
                Section("수유 시간") {
                    Stepper(
                        "왼쪽 \(store.breastLeftMinutes)분",
                        value: $store.breastLeftMinutes,
                        in: 0 ... 60
                    )
                    Stepper(
                        "오른쪽 \(store.breastRightMinutes)분",
                        value: $store.breastRightMinutes,
                        in: 0 ... 60
                    )
                }
            } else {
                Section("용량") {
                    Stepper(
                        "\(store.feedingMl) ml",
                        value: $store.feedingMl,
                        in: 0 ... 500,
                        step: 10
                    )
                }
            }

        case .temperature:
            Section("체온") {
                Stepper(
                    String(format: "%.1f °C", store.temperatureCelsius),
                    value: $store.temperatureCelsius,
                    in: 30 ... 45,
                    step: 0.1
                )
            }

        case .heightWeight:
            Section("키 / 몸무게") {
                HStack {
                    TextField("키", text: heightText)
                        .keyboardType(.decimalPad)
                    Text("cm").foregroundColor(.Semantic.secondaryText)
                }
                HStack {
                    TextField("몸무게", text: weightText)
                        .keyboardType(.decimalPad)
                    Text("kg").foregroundColor(.Semantic.secondaryText)
                }
            }

        case .bath, .snack:
            EmptyView()
        }
    }
}
