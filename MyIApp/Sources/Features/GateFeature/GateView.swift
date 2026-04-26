import ComposableArchitecture
import SwiftUI

struct GateView: View {
    let store: StoreOf<GateFeature>

    var body: some View {
        Group {
            switch store.state {
            case .loading: ProgressView()

            case .login:
                if let loginStore = store.scope(state: \.login, action: \.login) {
                    LoginView(store: loginStore)
                }

            case .childRegistration:
                if let childRegistrationStore = store.scope(
                    state: \.childRegistration,
                    action: \.childRegistration
                ) {
                    ChildRegistrationView(store: childRegistrationStore)
                }

            case .main:
                if let mainStore = store.scope(state: \.main, action: \.main) {
                    MainTabView(store: mainStore)
                }
            }
        }
        .onAppear { store.send(.view(.onAppear)) }
    }
}
