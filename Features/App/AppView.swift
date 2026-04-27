import ComposableArchitecture
import SwiftUI

public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let destinationStore = store.scope(state: \.destination, action: \.destination.presented) {
                switch destinationStore.case {
                case let .home(homeStore):
                    HomeView(store: homeStore)
                case let .babyRegister(registerStore):
                    RegisterMethodPickerView(store: registerStore)
                }
            } else {
                LoginView(store: store.scope(state: \.auth, action: \.auth))
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}
