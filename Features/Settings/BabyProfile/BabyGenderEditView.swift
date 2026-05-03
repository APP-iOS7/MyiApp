import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct BabyGenderEditView: View {
    @Bindable var store: StoreOf<BabyGenderEditFeature>

    public init(store: StoreOf<BabyGenderEditFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            SectionCard(spacing: Spacing.m) {
                Text("성별을 선택하세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(Gender.allCases, id: \.self) { gender in
                    CheckmarkRow(
                        title: gender.displayName,
                        font: .body,
                        isSelected: store.gender == gender
                    ) { store.gender = gender }
                }
            }

            Spacer()

            Button("저장") { store.send(.view(.saveButtonTapped)) }
                .buttonStyle(.primary)
                .disabled(!store.canSave)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("성별")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .loadingOverlay(isPresented: store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
