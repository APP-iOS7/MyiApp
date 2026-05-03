import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CaregiverListFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var currentUserID: String
        public var caregivers: IdentifiedArrayOf<Caregiver> = []
        @Presents public var alert: AlertState<Action.Alert>?

        public init(baby: Baby, currentUserID: String) {
            self.baby = baby
            self.currentUserID = currentUserID
        }

        public var isMainCaregiver: Bool {
            currentUserID == baby.mainCaregiverID
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction {
            case task
            case removeTapped(Caregiver.ID)
        }

        public enum InternalAction {
            case caregiversLoaded([Caregiver])
            case removeFailed(BabyError)
        }

        public enum Alert: Equatable {
            case confirmRemove(Caregiver.ID)
        }

        case view(ViewAction)
        case _internal(InternalAction)

        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.caregiverClient) var caregiverClient
    @Dependency(\.babyClient) var babyClient

    private enum CancelID { case stream }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.task):
                let ids = state.baby.caregiverIDs
                return .run { [caregiverClient] send in
                    for await caregivers in caregiverClient.streamCaregivers(ids) {
                        await send(._internal(.caregiversLoaded(caregivers)))
                    }
                }
                .cancellable(id: CancelID.stream, cancelInFlight: true)

            case let .view(.removeTapped(id)):
                guard state.isMainCaregiver,
                      id != state.baby.mainCaregiverID,
                      id != state.currentUserID
                else { return .none }
                let displayName = state.caregivers[id: id]?.displayName ?? "양육자"
                state.alert = AlertState {
                    TextState("연결 해제")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmRemove(id)) {
                        TextState("해제")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("\(displayName)님의 연결을 해제할까요?")
                }
                return .none

            case let ._internal(.caregiversLoaded(caregivers)):
                let mainID = state.baby.mainCaregiverID
                let sorted = caregivers.sorted { lhs, rhs in
                    if lhs.id == mainID { return true }
                    if rhs.id == mainID { return false }
                    return lhs.createdAt < rhs.createdAt
                }
                state.caregivers = IdentifiedArray(uniqueElements: sorted)
                return .none

            case let ._internal(.removeFailed(error)):
                state.alert = AlertState {
                    TextState("연결 해제 실패")
                } message: {
                    TextState(message(for: error))
                }
                return .none

            case let .alert(.presented(.confirmRemove(id))):
                let babyID = state.baby.id
                return .run { [babyClient] send in
                    do throws(BabyError) {
                        try await babyClient.removeCaregiver(babyID, id)
                    } catch {
                        await send(._internal(.removeFailed(error)))
                    }
                }

            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func message(for error: BabyError) -> String {
        switch error {
        case .unauthorized:
            "이 작업을 수행할 권한이 없어요."
        case .invalidInviteCode, .unexpected:
            "문제가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
}
