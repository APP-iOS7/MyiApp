import ComposableArchitecture
import Domain

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action {}

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
