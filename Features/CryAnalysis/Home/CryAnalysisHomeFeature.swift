import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CryAnalysisHomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var path = StackState<Path.State>()
        @Presents public var alert: AlertState<Action.Alert>?

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action {
        public enum ViewAction {
            case startTapped
            case recordsButtonTapped
        }

        public enum InternalAction {
            case permissionResolved(Bool)
        }

        public enum Alert: Equatable {
            case openSettingsTapped
        }

        case view(ViewAction)
        case _internal(InternalAction)

        case path(StackAction<Path.State, Path.Action>)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.audioRecorderClient) var audioRecorderClient
    @Dependency(\.openURL) var openURL

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.startTapped):
                return .run { [audioRecorderClient] send in
                    let granted = await audioRecorderClient.requestPermission()
                    await send(._internal(.permissionResolved(granted)))
                }

            case .view(.recordsButtonTapped):
                state.path.append(.recordList(CryRecordListFeature.State(baby: state.baby)))
                return .none

            case ._internal(.permissionResolved(true)):
                state.path.append(.analysis(CryAnalysisFeature.State(baby: state.baby)))
                return .none

            case ._internal(.permissionResolved(false)):
                state.alert = AlertState {
                    TextState("마이크 권한이 필요합니다")
                } actions: {
                    ButtonState(action: .openSettingsTapped) {
                        TextState("설정 열기")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("울음 분석을 시작하려면 설정 앱에서 마이크 권한을 켜주세요.")
                }
                return .none

            case .alert(.presented(.openSettingsTapped)):
                return .run { [openURL] _ in
                    guard let url = URL(string: "app-settings:") else { return }

                    _ = await openURL(url)
                }

            case .alert, .path:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path)
    }
}

extension CryAnalysisHomeFeature {
    @Reducer
    public enum Path {
        case analysis(CryAnalysisFeature)
        case recordList(CryRecordListFeature)
    }
}

extension CryAnalysisHomeFeature.Path.State: Equatable {}
