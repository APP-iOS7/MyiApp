import ComposableArchitecture
import Foundation

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var selectedDate: Date = .init()
        public var records: [Record] = [] // UI 표시용

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action {
        case onAppear
        case dateChanged(Date)
        case previousDayButtonTapped
        case nextDayButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 초기 데이터 로드 (필요시)
                state.records = Record.mockRecords
                return .none

            case let .dateChanged(date):
                state.selectedDate = date
                return .none

            case .previousDayButtonTapped:
                if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: state.selectedDate) {
                    state.selectedDate = newDate
                }
                return .none

            case .nextDayButtonTapped:
                if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: state.selectedDate) {
                    state.selectedDate = newDate
                }
                return .none
            }
        }
    }
}
