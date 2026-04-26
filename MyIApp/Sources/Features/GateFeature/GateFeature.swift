import ComposableArchitecture
import Foundation

@Reducer
struct GateFeature {
    @ObservableState
    enum State: Equatable {
        case loading
        case login(LoginFeature.State)
        case childRegistration(ChildRegistrationFeature.State)
        case main(MainTabFeature.State)
    }

    enum Action {
        enum ViewAction {
            case onAppear
            case logoutButtonTapped
        }

        enum InternalAction {
            case sessionLoaded(Session?)
            case babiesLoaded([Baby])
            case signedOut
        }

        case view(ViewAction)
        case `internal`(InternalAction)
        case login(LoginFeature.Action)
        case childRegistration(ChildRegistrationFeature.Action)
        case main(MainTabFeature.Action)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.babyClient) var babyClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .run { send in
                    let session = await authClient.currentSession()
                    await send(.internal(.sessionLoaded(session)))
                }

            case .view(.logoutButtonTapped):
                return .run { send in
                    try await authClient.signOut()
                    await send(.internal(.signedOut))
                }

            case let .internal(.sessionLoaded(session)):
                guard session != nil else {
                    state = .login(.init())
                    return .none
                }

                return fetchBabies()

            case let .internal(.babiesLoaded(babies)):
                if let baby = babies.first {
                    state = .main(.init(baby: baby))
                } else {
                    state = .childRegistration(.init())
                }
                return .none

            case .internal(.signedOut):
                state = .login(.init())
                return .none

            case .login(.delegate(.signedIn)):
                state = .loading
                return fetchBabies()

            case .login:
                return .none

            case .childRegistration(.delegate(.registrationCompleted)):
                state = .loading
                return fetchBabies()

            case .childRegistration:
                return .none

            case .main:
                return .none
            }
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifCaseLet(\.childRegistration, action: \.childRegistration) {
            ChildRegistrationFeature()
        }
        .ifCaseLet(\.main, action: \.main) {
            MainTabFeature()
        }
    }

    // MARK: - Private Helpers

    private func fetchBabies() -> Effect<Action> {
        .run { send in
            do {
                let babies = try await babyClient.fetchBabies()
                await send(.internal(.babiesLoaded(babies)))
            } catch {
                // 조회 실패 시 아이 없는 것으로 처리
                await send(.internal(.babiesLoaded([])))
            }
        }
    }
}
