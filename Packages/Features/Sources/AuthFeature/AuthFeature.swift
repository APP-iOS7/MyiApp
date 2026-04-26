import ComposableArchitecture
import Foundation

@Reducer
public struct AuthFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
