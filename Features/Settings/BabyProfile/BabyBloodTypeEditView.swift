import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct BabyBloodTypeEditView: View {
    @Bindable var store: StoreOf<BabyBloodTypeEditFeature>

    public init(store: StoreOf<BabyBloodTypeEditFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            SectionCard(spacing: Spacing.m) {
                Text("혈액형을 선택하세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(BloodType.allCases, id: \.self) { type in
                    CheckmarkRow(
                        title: "\(type.rawValue) 형",
                        font: .body,
                        isSelected: store.bloodType == type
                    ) { store.bloodType = type }
                }
            }

            Spacer()

            Button("저장") { store.send(.saveButtonTapped) }
                .buttonStyle(.primary)
                .disabled(!store.canSave)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("혈액형")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.Semantic.primaryAction)
        .loadingOverlay(isPresented: store.isSaving)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
