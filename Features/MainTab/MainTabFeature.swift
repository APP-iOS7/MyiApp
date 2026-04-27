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

        public init(session: Session, babies: [Baby], selectedTab: Tab = .home) {
            self.session = session
            self.babies = IdentifiedArray(uniqueElements: babies)
            self.selectedBabyID = babies.first?.id ?? UUID()
            self.selectedTab = selectedTab
        }

        public var selectedBaby: Baby? {
            babies[id: selectedBabyID]
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

extension MainTabFeature {
    public enum Tab: Hashable, Sendable {
        case home
        case note
        case voice
        case statistic
        case settings
    }
}
