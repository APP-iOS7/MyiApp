import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct NewBabyRegisterFeature {
    @ObservableState
    public struct State: Equatable {
        public var name: String = ""
        public var gender: Gender?
        public var birthDate: Date = .init()
        public var isTimeSelectionEnabled: Bool = false
        public var bloodType: BloodType?
        public var isSubmitting: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init() {}

        public var isSubmitEnabled: Bool {
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && gender != nil
                && bloodType != nil
                && !isSubmitting
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case submitTapped
        case submitSucceeded
        case submitFailed(BabyError)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable {}

        public enum Delegate: Equatable {
            case completed
        }
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.babyClient) var babyClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .submitTapped:
                guard state.isSubmitEnabled,
                      let gender = state.gender,
                      let bloodType = state.bloodType
                else { return .none }

                guard let session = authClient.current() else {
                    state.alert = makeAlert(for: .unauthorized)
                    return .none
                }

                state.isSubmitting = true

                let baby = Baby(
                    name: state.name,
                    birthDate: state.birthDate,
                    gender: gender,
                    bloodType: bloodType,
                    mainCaregiverID: session.uid,
                    caregiverIDs: [session.uid]
                )

                return .run { [babyClient] send in
                    do throws(BabyError) {
                        try await babyClient.registerNewBaby(baby)
                        await send(.submitSucceeded)
                    } catch {
                        await send(.submitFailed(error))
                    }
                }

            case .submitSucceeded:
                state.isSubmitting = false
                return .send(.delegate(.completed))

            case let .submitFailed(error):
                state.isSubmitting = false
                state.alert = makeAlert(for: error)
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func makeAlert(for error: BabyError) -> AlertState<Action.Alert> {
        AlertState {
            TextState("등록 실패")
        } message: {
            TextState(message(for: error))
        }
    }

    private func message(for error: BabyError) -> String {
        switch error {
        case .unauthorized:
            "로그인이 필요합니다."
        case .invalidInviteCode, .unexpected:
            "등록 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }
}
