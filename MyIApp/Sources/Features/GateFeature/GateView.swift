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

            case let .main(baby):
                VStack(spacing: 12) {
                    Text("\(baby.name) 메인 화면")
                    Button("로그아웃") {
                        store.send(.view(.logoutButtonTapped))
                    }
                }
            }
        }
        .onAppear { store.send(.view(.onAppear)) }
    }
}
