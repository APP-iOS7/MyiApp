import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct BabyNameEditView: View {
    @Bindable var store: StoreOf<BabyNameEditFeature>

    public init(store: StoreOf<BabyNameEditFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            SectionCard(spacing: Spacing.m) {
                Text("이름 / 태명을 입력하세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                UnderlinedTextField(
                    placeholder: "이름",
                    text: $store.name
                )
            }

            Spacer()

            Button("저장") { store.send(.saveButtonTapped) }
                .buttonStyle(.primary)
                .disabled(!store.canSave)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("이름 / 태명")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .loadingOverlay(isPresented: store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        BabyNameEditView(
            store: Store(
                initialState: BabyNameEditFeature.State(
                    baby: Baby(
                        name: "꼬미",
                        birthDate: Date(),
                        gender: .female,
                        bloodType: .a,
                        mainCaregiverID: "preview"
                    )
                )
            ) {
                BabyNameEditFeature()
            }
        )
    }
}
