import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var session: Session
        public var babies: IdentifiedArrayOf<Baby>
        public var isLoading: Bool = false
        public var path = StackState<Path.State>()
        @Presents public var alert: AlertState<Action.Alert>?

        public init(session: Session, babies: IdentifiedArrayOf<Baby>) {
            self.session = session
            self.babies = babies
        }

        public var displayName: String {
            session.displayName ?? session.email ?? "이름을 설정해주세요"
        }

        public var providerText: String {
            guard let provider = session.providerIDs.first else { return "" }
            switch provider {
            case "apple.com": return "Apple로 로그인"
            case "google.com": return "Google로 로그인"
            default: return ""
            }
        }

        public var appVersion: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signOutTapped
        case deleteAccountTapped
        case signOutConfirmed
        case deleteAccountConfirmed
        case signOutCompleted
        case signOutFailed(AuthError)
        case deleteAccountCompleted
        case deleteAccountFailed(AuthError)
        case alert(PresentationAction<Alert>)
        case path(StackActionOf<Path>)
        case delegate(Delegate)

        public enum Alert: Equatable {
            case confirmSignOut
            case confirmDeleteAccount
        }

        public enum Delegate: Equatable {
            case babyUpdated(Baby)
        }
    }

    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .signOutTapped:
                state.alert = AlertState {
                    TextState("로그아웃")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmSignOut) {
                        TextState("로그아웃")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("정말 로그아웃하시겠습니까?")
                }
                return .none

            case .deleteAccountTapped:
                state.alert = AlertState {
                    TextState("계정 삭제")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeleteAccount) {
                        TextState("삭제")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("계정 삭제 시, 모든 정보가 삭제됩니다.")
                }
                return .none

            case .signOutConfirmed:
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        try await authClient.signOut()
                        await send(.signOutCompleted)
                    } catch {
                        await send(.signOutFailed(error))
                    }
                }

            case .deleteAccountConfirmed:
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        try await authClient.deleteAccount()
                        await send(.deleteAccountCompleted)
                    } catch {
                        await send(.deleteAccountFailed(error))
                    }
                }

            case .signOutCompleted:
                state.isLoading = false
                return .none

            case let .signOutFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("오류")
                } message: {
                    TextState(message(for: error))
                }
                return .none

            case .deleteAccountCompleted:
                state.isLoading = false
                return .none

            case let .deleteAccountFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("오류")
                } message: {
                    TextState("계정 삭제 실패: \(message(for: error))")
                }
                return .none

            case .alert(.presented(.confirmSignOut)):
                return .send(.signOutConfirmed)

            case .alert(.presented(.confirmDeleteAccount)):
                return .send(.deleteAccountConfirmed)

            case .alert:
                return .none

            case let .path(.element(id: _, action: .babyProfile(.delegate(.editNameTapped(baby))))):
                state.path.append(.nameEdit(BabyNameEditFeature.State(baby: baby)))
                return .none

            case let .path(.element(id: _, action: .nameEdit(.delegate(.saved(baby))))):
                state.babies[id: baby.id] = baby
                state.path.removeLast()
                if let topID = state.path.ids.last {
                    state.path[id: topID] = .babyProfile(BabyProfileFeature.State(baby: baby))
                }
                return .send(.delegate(.babyUpdated(baby)))

            case .path, .delegate:
                return .none

            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path)
    }

    private func message(for error: AuthError) -> String {
        switch error {
        case .requiresRecentLogin:
            "다시 로그인해주세요."
        case .unexpected:
            "문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}

extension SettingsFeature {
    @Reducer
    public enum Path {
        case babyProfile(BabyProfileFeature)
        case nameEdit(BabyNameEditFeature)
    }
}

extension SettingsFeature.Path.State: Equatable {}
