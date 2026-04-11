import ComposableArchitecture
import SwiftUI

public struct ChildRegistrationView: View {
    let store: StoreOf<ChildRegistrationFeature>

    public var body: some View {
        NavigationStack(path: Bindable(store).scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                RoundedContainer(alignment: .listRowSeparatorLeading) {
                    Text(store.title)
                        .appSectionTitleStyle()
                        .padding(.bottom, DesignSystem.Spacing.defaultPadding)

                    CheckmarkRow(
                        title: store.newBabyTitle,
                        isSelected: store.selectedType == .new,
                        action: { store.send(.typeSelected(.new)) }
                    )

                    CheckmarkRow(
                        title: store.existingBabyTitle,
                        isSelected: store.selectedType == .existing,
                        action: { store.send(.typeSelected(.existing)) }
                    )
                }

                Spacer()

                Button(store.nextButtonTitle) { store.send(.nextButtonTapped) }
                    .buttonStyle(.primary)
            }
            .padding(.horizontal, DesignSystem.Spacing.defaultPadding)
            .navigationTitle(store.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(DesignSystem.Colors.backgroundPrimary)
        } destination: { store in
            switch store.state {
            case .newBaby:
                if let store = store.scope(state: \.newBaby, action: \.newBaby) {
                    NewBabyView(store: store)
                }

            case .existingBaby:
                if let store = store.scope(state: \.existingBaby, action: \.existingBaby) {
                    ExistingBabyView(store: store)
                }
            }
        }
    }
}

#Preview {
    ChildRegistrationView(
        store: Store(initialState: ChildRegistrationFeature.State()) {
            ChildRegistrationFeature()
        }
    )
}
