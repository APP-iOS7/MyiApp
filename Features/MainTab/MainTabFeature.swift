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
        public var cryAnalysis: CryAnalysisHomeFeature.State
        public var statistic: StatisticFeature.State
        public var settings: SettingsFeature.State

        public init?(session: Session, babies: [Baby], selectedTab: Tab = .home) {
            guard let firstBaby = babies.first else { return nil }
            self.session = session
            self.babies = IdentifiedArray(uniqueElements: babies)
            self.selectedBabyID = firstBaby.id
            self.selectedTab = selectedTab
            self.home = HomeFeature.State(baby: firstBaby)
            self.cryAnalysis = CryAnalysisHomeFeature.State(baby: firstBaby)
            self.statistic = StatisticFeature.State(baby: firstBaby)
            self.settings = SettingsFeature.State(
                session: session,
                babies: IdentifiedArray(uniqueElements: babies)
            )
        }

        public var selectedBaby: Baby? {
            babies[id: selectedBabyID]
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case cryAnalysis(CryAnalysisHomeFeature.Action)
        case statistic(StatisticFeature.Action)
        case settings(SettingsFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.cryAnalysis, action: \.cryAnalysis) {
            CryAnalysisHomeFeature()
        }
        Scope(state: \.statistic, action: \.statistic) {
            StatisticFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding(\.selectedBabyID):
                if let baby = state.selectedBaby {
                    state.home.baby = baby
                    state.cryAnalysis.baby = baby
                    state.statistic.baby = baby
                }
                return .none

            case .binding, .home, .cryAnalysis, .statistic, .settings:
                return .none
            }
        }
    }
}

extension MainTabFeature {
    public enum Tab: Hashable, Sendable {
        case home
        case note
        case cryAnalysis
        case statistic
        case settings
    }
}
