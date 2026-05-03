import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct AccountEditView: View {
    @Bindable var store: StoreOf<AccountEditFeature>

    public init(store: StoreOf<AccountEditFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            SectionCard(spacing: Spacing.m) {
                Text("사용자 이름을 입력하세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                UnderlinedTextField(
                    placeholder: "이름",
                    text: $store.name
                )
            }

            Spacer()

            Button("저장") { store.send(.view(.saveButtonTapped)) }
                .buttonStyle(.primary)
                .disabled(!store.canSave)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("사용자 이름")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .loadingOverlay(isPresented: store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
