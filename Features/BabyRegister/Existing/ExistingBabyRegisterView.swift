import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ExistingBabyRegisterView: View {
    @Bindable var store: StoreOf<ExistingBabyRegisterFeature>

    public init(store: StoreOf<ExistingBabyRegisterFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            SectionCard(spacing: Spacing.m) {
                Text("초대 코드를 입력하세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                UnderlinedTextField(
                    placeholder: "초대 코드를 입력하세요",
                    text: $store.inviteCode
                )
            }

            Spacer()

            Button("완료") { store.send(.view(.submitTapped)) }
                .buttonStyle(.primary)
                .disabled(!store.isSubmitEnabled)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("초대 코드 등록")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
