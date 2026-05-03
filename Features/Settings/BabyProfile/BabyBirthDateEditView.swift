import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct BabyBirthDateEditView: View {
    @Bindable var store: StoreOf<BabyBirthDateEditFeature>

    public init(store: StoreOf<BabyBirthDateEditFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            SectionCard(spacing: Spacing.m) {
                Text("출생일을 선택하세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DatePicker(
                    "날짜",
                    selection: $store.birthDate,
                    in: ...Date.now,
                    displayedComponents: .date
                )
            }

            Spacer()

            Button("저장") { store.send(.view(.saveButtonTapped)) }
                .buttonStyle(.primary)
                .disabled(!store.canSave)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("출생일")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .loadingOverlay(isPresented: store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
