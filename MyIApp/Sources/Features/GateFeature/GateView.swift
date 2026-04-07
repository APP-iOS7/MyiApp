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

            case .main: EmptyView()
            }
        }
        .onAppear { store.send(.view(.onAppear)) }
    }
}
