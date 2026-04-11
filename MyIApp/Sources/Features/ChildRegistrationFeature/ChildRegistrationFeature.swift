import ComposableArchitecture
import Foundation

@Reducer
public struct ChildRegistrationFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        var path = StackState<Path.State>()
        var selectedType: RegistrationType = .new

        var isLoading: Bool = false
        var errorMessage: String?

        // 텍스트 상수
        let title: String = "등록 방식을 선택해주세요"
        let newBabyTitle: String = "새로운 아이 정보 등록"
        let existingBabyTitle: String = "초대받은 아이 등록"
        let nextButtonTitle: String = "다음"
        let navigationTitle: String = "아이 등록"
    }

    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case typeSelected(RegistrationType)
        case nextButtonTapped

        case delegate(DelegateAction)

        public enum DelegateAction: Equatable {
            case registrationCompleted
        }
    }

    public enum RegistrationType: Equatable {
        case new
        case existing
    }

    @Reducer
    public enum Path {
        case newBaby(NewBabyFeature)
        case existingBaby(ExistingBabyFeature)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .typeSelected(type):
                state.selectedType = type
                return .none

            case .nextButtonTapped:
                switch state.selectedType {
                case .new:
                    state.path.append(.newBaby(.init()))
                case .existing:
                    state.path.append(.existingBaby(.init()))
                }
                return .none

            case .delegate, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension ChildRegistrationFeature.Path.State: Equatable {}
extension ChildRegistrationFeature.Path.Action: Equatable {}
