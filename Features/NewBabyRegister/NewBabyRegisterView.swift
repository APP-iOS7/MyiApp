import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct NewBabyRegisterView: View {
    @Bindable var store: StoreOf<NewBabyRegisterFeature>

    public init(store: StoreOf<NewBabyRegisterFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                genderSection
                nameSection
                birthDateSection
                heightSection
                weightSection
                bloodTypeSection

                Button("완료") { store.send(.submitTapped) }
                    .buttonStyle(.primary)
                    .disabled(!store.isSubmitEnabled)
                    .padding(.top, Spacing.s)
            }
            .padding(Spacing.m)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("새로운 아이 정보 등록")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private var genderSection: some View {
        SectionCard(spacing: Spacing.m) {
            sectionHeader("성별")
            CheckmarkRow(
                title: "남자 아이",
                font: .body,
                isSelected: store.gender == .male
            ) { store.gender = .male }
            CheckmarkRow(
                title: "여자 아이",
                font: .body,
                isSelected: store.gender == .female
            ) { store.gender = .female }
        }
    }

    private var nameSection: some View {
        SectionCard(spacing: Spacing.m) {
            sectionHeader("이름 / 태명")
            UnderlinedTextField(
                placeholder: "이름을 입력하세요",
                text: $store.name
            )
        }
    }

    private var birthDateSection: some View {
        SectionCard(spacing: Spacing.m) {
            sectionHeader("출생일")
            DatePicker(
                "날짜",
                selection: $store.birthDate,
                in: ...Date.now,
                displayedComponents: .date
            )
            Toggle("시간 입력", isOn: $store.isTimeSelectionEnabled.animation())
            if store.isTimeSelectionEnabled {
                DatePicker(
                    "시간",
                    selection: $store.birthDate,
                    in: ...Date.now,
                    displayedComponents: .hourAndMinute
                )
            }
        }
    }

    private var heightSection: some View {
        SectionCard(spacing: Spacing.m) {
            sectionHeader("키")
            UnderlinedTextField(
                placeholder: "키를 입력하세요",
                text: $store.heightText,
                keyboardType: .decimalPad
            ) {
                Text("cm")
                    .foregroundColor(.Semantic.secondaryText)
                    .font(.title2)
            }
        }
    }

    private var weightSection: some View {
        SectionCard(spacing: Spacing.m) {
            sectionHeader("몸무게")
            UnderlinedTextField(
                placeholder: "몸무게를 입력하세요",
                text: $store.weightText,
                keyboardType: .decimalPad
            ) {
                Text("kg")
                    .foregroundColor(.Semantic.secondaryText)
                    .font(.title2)
            }
        }
    }

    private var bloodTypeSection: some View {
        SectionCard(spacing: Spacing.m) {
            sectionHeader("혈액형")
            ForEach(BloodType.allCases, id: \.self) { type in
                CheckmarkRow(
                    title: "\(type.rawValue) 형",
                    font: .body,
                    isSelected: store.bloodType == type
                ) { store.bloodType = type }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.Style.sectionLabel)
            .foregroundColor(.Semantic.sectionHeading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        NewBabyRegisterView(
            store: Store(initialState: NewBabyRegisterFeature.State()) {
                NewBabyRegisterFeature()
            }
        )
    }
}
