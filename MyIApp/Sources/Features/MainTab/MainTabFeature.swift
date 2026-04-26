import ComposableArchitecture
import Foundation

@Reducer
public struct MainTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var main: MainFeature.State
        public var selectedTab: Tab = .home

        public enum Tab: Hashable {
            case home
            case note
            case analysis
            case stats
            case more
        }

        public init(baby: Baby) {
            main = .init(baby: baby)
        }
    }

    public enum Action {
        case tabSelected(State.Tab)
        case main(MainFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .main:
                return .none
            }
        }
    }
}
