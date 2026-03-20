import AuthFeature
import ComposableArchitecture
import SwiftUI

@Reducer
public struct RootFeature {
    @ObservableState
    public enum State: Equatable {
        case auth(AuthFeature.State)
        case main // HomeFeature 전환 시 구현

        public init() {
            self = .auth(AuthFeature.State())
        }
    }

    public enum Action {
        case auth(AuthFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .auth(.loginResponse(.success)):
                state = .main
                return .none

            case .auth:
                return .none
            }
        }
        .ifCaseLet(\.auth, action: \.auth) {
            AuthFeature()
        }
    }
}

public struct RootView: View {
    let store: StoreOf<RootFeature>

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
        switch self.store.state {
        case .auth:
            if let authStore = store.scope(state: \.auth, action: \.auth) {
                AuthView(store: authStore)
            }

        case .main:
            Text("Main Content") // HomeFeatureView 연동
        }
    }
}
