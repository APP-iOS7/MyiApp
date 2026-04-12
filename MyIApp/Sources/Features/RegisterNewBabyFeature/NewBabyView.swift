import ComposableArchitecture
import SwiftUI

public struct NewBabyView: View {
    @Bindable var store: StoreOf<NewBabyFeature>

    @FocusState private var focusedField: NewBabyFeature.Field?

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.defaultPadding) {
                genderSection
                nameSection
                birthDateSection
                heightSection
                weightSection
                bloodTypeSection

                submitButton
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.defaultPadding)
        .bind($store.focusedField, to: $focusedField)
        .onTapGesture { store.send(.backgroundTapped) }
        .navigationTitle(store.navigationTitle)
        .background(DesignSystem.Colors.backgroundPrimary)
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    // MARK: - Sections

    private var genderSection: some View {
        RoundedContainer(alignment: .leading) {
            Text(store.sectionTitleGender)
                .appSectionTitleStyle()
                .padding(.bottom, DesignSystem.Spacing.defaultPadding)

            CheckmarkRow(title: store.genderMale, isSelected: store.gender == .male) {
                store.send(.genderTapped(.male), animation: .default)
            }
            CheckmarkRow(title: store.genderFemale, isSelected: store.gender == .female) {
                store.send(.genderTapped(.female), animation: .default)
            }
        }
    }

    private var nameSection: some View {
        RoundedContainer(alignment: .leading) {
            Text(store.sectionTitleName)
                .appSectionTitleStyle()
                .padding(.bottom, DesignSystem.Spacing.defaultPadding)

            UnderlinedTextField(
                placeholder: store.placeholderName,
                text: $store.name,
                keyboardType: .default,
                suffix: nil,
                showClearButton: store.isNameEntered,
                onClear: { store.send(.clearNameTapped, animation: .easeInOut(duration: 0.2)) }
            )
            .submitLabel(.done)
            .focused($focusedField, equals: .name)
        }
        .onSubmit { store.send(.nameSubmitted, animation: .default) }
    }

    private var birthDateSection: some View {
        RoundedContainer(alignment: .leading, spacing: DesignSystem.Spacing.defaultPadding) {
            Text(store.sectionTitleBirthDate)
                .appSectionTitleStyle()

            DatePicker(
                store.dateLabel,
                selection: $store.birthDate,
                displayedComponents: .date
            )
            .focused($focusedField, equals: .birthDate)
            Toggle(store.timeToggleLabel, isOn: $store.isTimeSelectionEnabled.animation(.default))
            if store.isTimeSelectionEnabled {
                DatePicker(
                    store.timeLabel,
                    selection: $store.birthDate,
                    displayedComponents: .hourAndMinute
                )
                .focused($focusedField, equals: .birthDate)
            }
        }
        .onSubmit { store.send(.birthDateSubmitted, animation: .default) }
    }

    private var heightSection: some View {
        RoundedContainer(alignment: .leading) {
            Text(store.sectionTitleHeight)
                .appSectionTitleStyle()
                .padding(.bottom, DesignSystem.Spacing.defaultPadding)

            UnderlinedTextField(
                placeholder: store.placeholderHeight,
                text: $store.height,
                keyboardType: .decimalPad,
                suffix: store.suffixHeight,
                showClearButton: store.isHeightEntered,
                onClear: {
                    store.send(.clearHeightTapped, animation: .easeInOut(duration: 0.2))
                }
            )
            .focused($focusedField, equals: .height)
        }
        .onSubmit { store.send(.heightSubmitted, animation: .default) }
    }

    private var weightSection: some View {
        RoundedContainer(alignment: .leading) {
            Text(store.sectionTitleWeight)
                .appSectionTitleStyle()
                .padding(.bottom, DesignSystem.Spacing.defaultPadding)

            UnderlinedTextField(
                placeholder: store.placeholderWeight,
                text: $store.weight,
                keyboardType: .decimalPad,
                suffix: store.suffixWeight,
                showClearButton: store.isWeightEntered,
                onClear: {
                    store.send(.clearWeightTapped, animation: .easeInOut(duration: 0.2))
                }
            )
            .focused($focusedField, equals: .weight)
        }
        .onSubmit { store.send(.weightSubmitted, animation: .default) }
    }

    private var bloodTypeSection: some View {
        RoundedContainer(alignment: .leading) {
            Text(store.sectionTitleBloodType)
                .appSectionTitleStyle()
                .padding(.bottom, DesignSystem.Spacing.defaultPadding)

            CheckmarkRow(title: store.bloodTypeA, isSelected: store.bloodType == .a) {
                store.send(.bloodTypeTapped(.a), animation: .default)
            }
            CheckmarkRow(title: store.bloodTypeB, isSelected: store.bloodType == .b) {
                store.send(.bloodTypeTapped(.b), animation: .default)
            }
            CheckmarkRow(title: store.bloodTypeO, isSelected: store.bloodType == .o) {
                store.send(.bloodTypeTapped(.o), animation: .default)
            }
            CheckmarkRow(title: store.bloodTypeAB, isSelected: store.bloodType == .ab) {
                store.send(.bloodTypeTapped(.ab), animation: .default)
            }
        }
    }

    private var submitButton: some View {
        Button(store.submitButtonTitle) { store.send(.registerButtonTapped) }
            .buttonStyle(.primary)
            .disabled(!store.isButtonEnabled)
            .padding(.vertical, DesignSystem.Spacing.defaultPadding)
    }
}

#Preview {
    NavigationStack {
        NewBabyView(
            store: Store(
                initialState: NewBabyFeature.State()
            ) {
                NewBabyFeature()
            }
        )
    }
}
