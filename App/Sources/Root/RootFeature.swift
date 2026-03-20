import AuthFeature
import ComposableArchitecture
import Core
import Domain
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

    public enum Action: Equatable {
        case auth(AuthFeature.Action)
        case checkAuth
        case authCheckResponse(Result<Route, CaregiverError>)
    }

    public enum Route: Equatable {
        case login
        case registerBaby
        case main
    }

    @Dependency(\.authClient)
    var authClient
    @Dependency(\.caregiverClient)
    var caregiverClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .checkAuth:
                return .run { send in
                    do {
                        guard let user = try await authClient.currentUser() else {
                            await send(.authCheckResponse(.success(.login)))
                            return
                        }

                        let caregiver = try await caregiverClient.fetchCaregiver(user.id)
                        if caregiver.lastSelectedBabyID == nil {
                            await send(.authCheckResponse(.success(.registerBaby)))
                        } else {
                            await send(.authCheckResponse(.success(.main)))
                        }
                    } catch {
                        await send(.authCheckResponse(.success(.login)))
                    }
                }

            case let .authCheckResponse(.success(route)):
                switch route {
                case .login:
                    state = .auth(.login(AuthFeature.LoginFeature.State()))
                case .registerBaby:
                    state = .auth(.registerBaby(AuthFeature.RegisterBabyFeature.State()))
                case .main:
                    state = .main
                }
                return .none

            case .auth(.login(.loginResponse(.success))):
                return .send(.checkAuth)

            case .auth(.registerBaby(.delegate(.registered))):
                state = .main
                return .none

            case .auth, .authCheckResponse:
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
        switch store.state {
        case .auth:
            if let authStore = store.scope(state: \.auth, action: \.auth) {
                AuthView(store: authStore)
            }

        case .main:
            Text("Main Content (HomeView)")
                .onAppear {
                    print("Main Content Shown")
                }
        }
    }
}
