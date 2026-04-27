import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MainTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: Tab = .home
        public var session: Session

        public init(session: Session, selectedTab: Tab = .home) {
            self.session = session
            self.selectedTab = selectedTab
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
