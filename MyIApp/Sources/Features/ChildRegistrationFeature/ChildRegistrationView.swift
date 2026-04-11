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
                Text("신규 아이 등록 화면 (준비 중)")
            case .existingBaby:
                Text("초대 코드 등록 화면 (준비 중)")
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
