import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MainTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: Tab = .home
        public var session: Session
        public var babies: IdentifiedArrayOf<Baby>
        public var selectedBabyID: Baby.ID
        public var home: HomeFeature.State

        public init?(session: Session, babies: [Baby], selectedTab: Tab = .home) {
            guard let firstBaby = babies.first else { return nil }
            self.session = session
            self.babies = IdentifiedArray(uniqueElements: babies)
            self.selectedBabyID = firstBaby.id
            self.selectedTab = selectedTab
            self.home = HomeFeature.State(baby: firstBaby)
        }

        public var selectedBaby: Baby? {
            babies[id: selectedBabyID]
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding(\.selectedBabyID):
                if let baby = state.selectedBaby {
                    state.home.baby = baby
                }
                return .none

            case .binding, .home:
                return .none
            }
        }
    }
}

extension MainTabFeature {
    public enum Tab: Hashable, Sendable {
        case home
        case note
        case voice
        case statistic
        case settings
    }
}
