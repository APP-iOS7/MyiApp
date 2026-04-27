import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct RegisterMethodPickerView: View {
    @Bindable var store: StoreOf<BabyRegisterFeature>

    public init(store: StoreOf<BabyRegisterFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                SectionCard(spacing: Spacing.l) {
                    Text("등록 방식을 선택해주세요")
                        .font(.Style.sectionTitle)
                        .foregroundColor(.Semantic.sectionHeading)

                    VStack(spacing: Spacing.l) {
                        CheckmarkRow(
                            title: "새로운 아이 정보 등록",
                            isSelected: store.selectedMethod == .newBaby
                        ) { store.send(.methodSelected(.newBaby)) }
                        CheckmarkRow(
                            title: "초대받은 아이 등록",
                            isSelected: store.selectedMethod == .existingBaby
                        ) { store.send(.methodSelected(.existingBaby)) }
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
        } destination: { destinationStore in
            switch destinationStore.case {
            case let .newBaby(newBabyStore):
                NewBabyRegisterView(store: newBabyStore)
            case let .existingBaby(existingStore):
                ExistingBabyRegisterView(store: existingStore)
            }
        }
    }
}

#Preview {
    RegisterMethodPickerView(
        store: Store(initialState: BabyRegisterFeature.State()) {
            BabyRegisterFeature()
        }
    )
}
