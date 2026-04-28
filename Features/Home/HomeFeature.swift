import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var selectedDate: Date
        public var records: [CareRecord]

        public init(
            baby: Baby,
            selectedDate: Date = Date(),
            records: [CareRecord] = []
        ) {
            self.baby = baby
            self.selectedDate = selectedDate
            self.records = records
        }

        /// 선택된 날짜의 기록만 필터링 (createdAt 오름차순).
        var filteredRecords: [CareRecord] {
            let cal = Calendar.current
            return records
                .filter { cal.isDate($0.createdAt, inSameDayAs: selectedDate) }
                .sorted { $0.createdAt < $1.createdAt }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
