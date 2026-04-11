import ComposableArchitecture
import Foundation

@Reducer
public struct NewBabyFeature: Sendable {
    public enum Field: Hashable {
        case name
        case birthDate
        case height
        case weight
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}

        @Presents public var alert: AlertState<Action.Alert>?

        public var name: String = ""
        public var gender: Gender?
        public var birthDate: Date = .init()
        public var isTimeSelectionEnabled: Bool = false
        public var height: String = ""
        public var weight: String = ""
        public var bloodType: BloodType?

        public var focusedField: Field?

        // 레거시의 Bool 플래그들
        public var isNameEntered: Bool = false
        public var isGenderSelected: Bool = false
        public var isBirthDateSelected: Bool = true
        public var isHeightEntered: Bool = false
        public var isWeightEntered: Bool = false
        public var isBloodTypeSelected: Bool = false

        // 텍스트 상수
        public let navigationTitle: String = "새로운 아이 정보 등록"
        public let sectionTitleGender: String = "성별"
        public let genderMale: String = "남자 아이"
        public let genderFemale: String = "여자 아이"

        public let sectionTitleName: String = "이름 / 태명"
        public let placeholderName: String = "이름을 입력하세요"

        public let sectionTitleBirthDate: String = "출생일"
        public let dateLabel: String = "날짜"
        public let timeToggleLabel: String = "시간 입력"
        public let timeLabel: String = "시간"

        public let sectionTitleHeight: String = "키"
        public let placeholderHeight: String = "키를 입력하세요"
        public let suffixHeight: String = "cm"

        public let sectionTitleWeight: String = "몸무게"
        public let placeholderWeight: String = "몸무게를 입력하세요"
        public let suffixWeight: String = "kg"

        public let sectionTitleBloodType: String = "혈액형"
        public let bloodTypeA: String = "A 형"
        public let bloodTypeB: String = "B 형"
        public let bloodTypeO: String = "O 형"
        public let bloodTypeAB: String = "AB 형"

        public let submitButtonTitle: String = "완료"

        public var isButtonEnabled: Bool {
            isNameEntered && isGenderSelected && isHeightEntered && isWeightEntered && isBloodTypeSelected &&
                isBirthDateSelected
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)

        // UI Actions
        case genderTapped(Gender)
        case bloodTypeTapped(BloodType)
        case clearNameTapped
        case clearHeightTapped
        case clearWeightTapped
        case registerButtonTapped

        // Form Navigation Actions
        case nameSubmitted
        case birthDateSubmitted
        case heightSubmitted
        case weightSubmitted
        case backgroundTapped

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case registrationCompleted
        }

        public enum Alert: Equatable {
            case completeRegistration
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.name):
                state.isNameEntered = !state.name.isEmpty
                return .none

            case .binding(\.height):
                let filtered = state.height.filter { $0.isNumber || $0 == "." }
                if state.height != filtered {
                    state.height = filtered
                }
                state.isHeightEntered = !filtered.isEmpty
                return .none

            case .binding(\.weight):
                let filtered = state.weight.filter { $0.isNumber || $0 == "." }
                if state.weight != filtered {
                    state.weight = filtered
                }
                state.isWeightEntered = !filtered.isEmpty
                return .none

            case .binding(\.birthDate), .binding(\.isTimeSelectionEnabled):
                state.isBirthDateSelected = true
                return .none

            case .binding:
                return .none

            case let .genderTapped(gender):
                state.gender = gender
                state.isGenderSelected = true
                state.focusedField = .name
                return .none

            case let .bloodTypeTapped(bloodType):
                state.bloodType = bloodType
                state.isBloodTypeSelected = true
                state.focusedField = nil
                return .none

            case .clearNameTapped:
                state.name = ""
                state.isNameEntered = false
                return .none

            case .clearHeightTapped:
                state.height = ""
                state.isHeightEntered = false
                state.focusedField = .height
                return .none

            case .clearWeightTapped:
                state.weight = ""
                state.isWeightEntered = false
                state.focusedField = .weight
                return .none

            case .nameSubmitted:
                if state.isNameEntered {
                    state.focusedField = .birthDate
                } else {
                    state.focusedField = nil
                }
                return .none

            case .birthDateSubmitted:
                if !state.isHeightEntered {
                    state.focusedField = .height
                } else {
                    state.focusedField = nil
                }
                return .none

            case .heightSubmitted:
                if state.weight.isEmpty {
                    state.focusedField = .weight
                } else {
                    state.focusedField = nil
                }
                return .none

            case .weightSubmitted:
                state.focusedField = nil
                return .none

            case .backgroundTapped:
                state.focusedField = nil
                return .none

            case .registerButtonTapped:
                state.focusedField = nil
                return .send(.delegate(.registrationCompleted))

            case .delegate:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
