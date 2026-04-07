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

            case .main:
                VStack(spacing: 12) {
                    Text("로그인 완료")
                    Button("로그아웃") {
                        store.send(.view(.logoutButtonTapped))
                    }
                }
            }
        }
        .onAppear { store.send(.view(.onAppear)) }
    }
}
