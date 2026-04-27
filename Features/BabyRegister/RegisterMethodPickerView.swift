import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct RegisterMethodPickerView: View {
    @Bindable var store: StoreOf<BabyRegisterFeature>

    public init(store: StoreOf<BabyRegisterFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            SectionCard(spacing: Spacing.l) {
                Text("등록 방식을 선택해주세요")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)

                VStack(spacing: 0) {
                    CheckmarkRow(
                        title: "새로운 아이 정보 등록",
                        isSelected: store.selectedMethod == .newBaby
                    ) { store.send(.methodSelected(.newBaby)) }
                        .padding(.vertical, Spacing.m)
                    CheckmarkRow(
                        title: "초대받은 아이 등록",
                        isSelected: store.selectedMethod == .existingBaby
                    ) { store.send(.methodSelected(.existingBaby)) }
                        .padding(.vertical, Spacing.m)
                }
            }

            Spacer()

            Button("다음") { store.send(.nextTapped) }
                .buttonStyle(.primary)
        }
        .padding(Spacing.m)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("아이 등록")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RegisterMethodPickerView(
            store: Store(initialState: BabyRegisterFeature.State()) {
                BabyRegisterFeature()
            }
        )
    }
}
