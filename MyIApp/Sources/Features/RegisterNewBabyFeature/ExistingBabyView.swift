import ComposableArchitecture
import SwiftUI

public struct ExistingBabyView: View {
    @Bindable var store: StoreOf<ExistingBabyFeature>

    public init(store: StoreOf<ExistingBabyFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.defaultPadding) {
            RoundedContainer(alignment: .leading) {
                Text(store.sectionTitle)
                    .appSectionTitleStyle()
                    .padding(.bottom, DesignSystem.Spacing.defaultPadding)

                Text(store.description)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .padding(.bottom, DesignSystem.Spacing.itemSpacing)

                UnderlinedTextField(
                    placeholder: store.placeholderCode,
                    text: $store.invitationCode,
                    keyboardType: .asciiCapable, // 영문/숫자 코드 전제
                    showClearButton: !store.invitationCode.isEmpty,
                    onClear: { store.invitationCode = "" }
                )
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
            }

            Spacer()

            submitButton
        }
        .padding(.horizontal, DesignSystem.Spacing.defaultPadding)
        .navigationTitle(store.navigationTitle)
        .background(DesignSystem.Colors.backgroundPrimary)
        .alert($store.scope(state: \.alert, action: \.alert))
        .overlay {
            if store.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
    }

    private var submitButton: some View {
        Button(store.submitButtonTitle) {
            store.send(.submitButtonTapped)
        }
        .buttonStyle(.primary)
        .disabled(!store.isButtonEnabled)
    }
}

#Preview {
    NavigationStack {
        ExistingBabyView(
            store: Store(initialState: ExistingBabyFeature.State()) {
                ExistingBabyFeature()
            }
        )
    }
}
