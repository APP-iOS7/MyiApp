import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct BabyRegisterFlowView: View {
    @Bindable var store: StoreOf<BabyRegisterFlowFeature>

    public init(store: StoreOf<BabyRegisterFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            RegisterMethodPickerView(store: store.scope(state: \.picker, action: \.picker))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") { store.send(.cancelTapped) }
                    }
                }
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
    BabyRegisterFlowView(
        store: Store(initialState: BabyRegisterFlowFeature.State()) {
            BabyRegisterFlowFeature()
        }
    )
}
