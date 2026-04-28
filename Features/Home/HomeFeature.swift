import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var selectedDate: Date

        public init(baby: Baby, selectedDate: Date = Date()) {
            self.baby = baby
            self.selectedDate = selectedDate
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
