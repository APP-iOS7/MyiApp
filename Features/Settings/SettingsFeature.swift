import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        public var session: Session
        public var caregiver: Caregiver
        public var babies: IdentifiedArrayOf<Baby>
        public var isLoading: Bool = false
        public var path = StackState<Path.State>()
        @Presents public var alert: AlertState<Action.Alert>?
        @Presents public var babyRegister: BabyRegisterFlowFeature.State?

        public init(session: Session, caregiver: Caregiver, babies: IdentifiedArrayOf<Baby>) {
            self.session = session
            self.caregiver = caregiver
            self.babies = babies
        }

        public var displayName: String {
            caregiver.displayName ?? session.email ?? "이름을 설정해주세요"
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
        public enum ViewAction {
            case task
            case signOutTapped
            case deleteAccountTapped
            case signOutConfirmed
            case deleteAccountConfirmed
            case addBabyTapped
        }

        public enum InternalAction {
            case signOutCompleted
            case signOutFailed(AuthError)
            case deleteAccountCompleted
            case deleteAccountFailed(AuthError)
        }

        public enum Alert: Equatable {
            case confirmSignOut
            case confirmDeleteAccount
        }

        case view(ViewAction)
        case _internal(InternalAction)

        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case babyRegister(PresentationAction<BabyRegisterFlowFeature.Action>)
        case path(StackActionOf<Path>)
    }

    @Dependency(\.analytics) var analytics
    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .view(.task):
                return .run { [analytics] _ in analytics.trackScreen(.settings) }

            case .view(.signOutTapped):
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

            case .view(.deleteAccountTapped):
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

            case .view(.addBabyTapped):
                state.babyRegister = BabyRegisterFlowFeature.State()
                return .none

            case .view(.signOutConfirmed):
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        try await authClient.signOut()
                        await send(._internal(.signOutCompleted))
                    } catch {
                        await send(._internal(.signOutFailed(error)))
                    }
                }

            case .view(.deleteAccountConfirmed):
                state.isLoading = true
                return .run { [authClient] send in
                    do throws(AuthError) {
                        try await authClient.deleteAccount()
                        await send(._internal(.deleteAccountCompleted))
                    } catch {
                        await send(._internal(.deleteAccountFailed(error)))
                    }
                }

            case ._internal(.signOutCompleted):
                state.isLoading = false
                return .none

            case let ._internal(.signOutFailed(error)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("오류")
                } message: {
                    TextState(message(for: error))
                }
                return .none

            case ._internal(.deleteAccountCompleted):
                state.isLoading = false
                return .none

            case let ._internal(.deleteAccountFailed(error)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("오류")
                } message: {
                    TextState("계정 삭제 실패: \(message(for: error))")
                }
                return .none

            case .alert(.presented(.confirmSignOut)):
                return .send(.view(.signOutConfirmed))

            case .alert(.presented(.confirmDeleteAccount)):
                return .send(.view(.deleteAccountConfirmed))

            case .alert:
                return .none

            case .babyRegister(.presented(.delegate(.cancelled))):
                state.babyRegister = nil
                return .none

            case .babyRegister(.presented(.delegate(.babyRegistered))):
                state.babyRegister = nil
                return .none

            case .babyRegister:
                return .none

            case let .path(.element(id: _, action: .babyProfile(.delegate(.editNameTapped(baby))))):
                state.path.append(.nameEdit(BabyNameEditFeature.State(baby: baby)))
                return .none

            case let .path(.element(id: _, action: .babyProfile(.delegate(.editBirthDateTapped(baby))))):
                state.path.append(.birthDateEdit(BabyBirthDateEditFeature.State(baby: baby)))
                return .none

            case let .path(.element(id: _, action: .babyProfile(.delegate(.editGenderTapped(baby))))):
                state.path.append(.genderEdit(BabyGenderEditFeature.State(baby: baby)))
                return .none

            case let .path(.element(id: _, action: .babyProfile(.delegate(.editBloodTypeTapped(baby))))):
                state.path.append(.bloodTypeEdit(BabyBloodTypeEditFeature.State(baby: baby)))
                return .none

            case let .path(.element(id: _, action: .babyProfile(.delegate(.editCaregiversTapped(baby))))):
                state.path.append(.caregiverList(CaregiverListFeature.State(
                    baby: baby,
                    currentUserID: state.session.uid
                )))
                return .none

            case .path:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$babyRegister, action: \.babyRegister) {
            BabyRegisterFlowFeature()
        }
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
        case accountEdit(AccountEditFeature)
        case babyProfile(BabyProfileFeature)
        case nameEdit(BabyNameEditFeature)
        case birthDateEdit(BabyBirthDateEditFeature)
        case genderEdit(BabyGenderEditFeature)
        case bloodTypeEdit(BabyBloodTypeEditFeature)
        case caregiverList(CaregiverListFeature)
    }
}

extension SettingsFeature.Path.State: Equatable {}
