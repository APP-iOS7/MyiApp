import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MainTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTab: Tab = .home
        public var session: Session
        public var caregiver: Caregiver
        public var babies: IdentifiedArrayOf<Baby>
        public var selectedBabyID: Baby.ID
        public var home: HomeFeature.State
        public var note: NoteHomeFeature.State
        public var cryAnalysis: CryAnalysisHomeFeature.State
        public var statistic: StatisticFeature.State
        public var settings: SettingsFeature.State
        public var notificationSync: NotificationSyncFeature.State

        public init?(session: Session, caregiver: Caregiver, babies: [Baby], selectedTab: Tab = .home) {
            guard let firstBaby = babies.first else { return nil }
            self.session = session
            self.caregiver = caregiver
            self.babies = IdentifiedArray(uniqueElements: babies)
            selectedBabyID = firstBaby.id
            self.selectedTab = selectedTab
            var initialHome = HomeFeature.State(baby: firstBaby)
            initialHome.babies = IdentifiedArray(uniqueElements: babies)
            home = initialHome
            note = NoteHomeFeature.State(baby: firstBaby)
            cryAnalysis = CryAnalysisHomeFeature.State(baby: firstBaby)
            statistic = StatisticFeature.State(baby: firstBaby)
            settings = SettingsFeature.State(
                session: session,
                caregiver: caregiver,
                babies: IdentifiedArray(uniqueElements: babies)
            )
            notificationSync = NotificationSyncFeature.State(babyID: firstBaby.id)
        }

        public var selectedBaby: Baby? {
            babies[id: selectedBabyID]
        }
    }

    public enum Action: BindableAction {
        public enum InternalAction {
            case babiesLoaded([Baby])
            case caregiverLoaded(Caregiver?)
        }

        case home(HomeFeature.Action)
        case note(NoteHomeFeature.Action)
        case cryAnalysis(CryAnalysisHomeFeature.Action)
        case statistic(StatisticFeature.Action)
        case settings(SettingsFeature.Action)
        case notificationSync(NotificationSyncFeature.Action)

        case binding(BindingAction<State>)
        case _internal(InternalAction)

        case task
    }

    @Dependency(\.babyClient) var babyClient
    @Dependency(\.caregiverClient) var caregiverClient

    private enum CancelID {
        case babiesStream
        case caregiverStream
    }

    public init() {}

    private func propagateSelectedBaby(into state: inout State) {
        guard let baby = state.selectedBaby else { return }
        state.home.baby = baby
        state.note.baby = baby
        state.cryAnalysis.baby = baby
        state.statistic.baby = baby
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.note, action: \.note) {
            NoteHomeFeature()
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
        Scope(state: \.notificationSync, action: \.notificationSync) {
            NotificationSyncFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding(\.selectedBabyID):
                propagateSelectedBaby(into: &state)
                return .send(.notificationSync(.babyChanged(state.selectedBabyID)))

            case let .home(.delegate(.babyChangeRequested(id))):
                state.selectedBabyID = id
                propagateSelectedBaby(into: &state)
                return .send(.notificationSync(.babyChanged(id)))

            case .binding:
                return .none

            case .cryAnalysis, .home, .note, .notificationSync, .settings, .statistic:
                return .none

            case .task:
                return .merge(
                    .send(.notificationSync(.task)),
                    .run { [babyClient] send in
                        for await babies in babyClient.streamBabies() {
                            await send(._internal(.babiesLoaded(babies)))
                        }
                    }
                    .cancellable(id: CancelID.babiesStream, cancelInFlight: true),
                    .run { [caregiverClient] send in
                        for await caregiver in caregiverClient.streamCaregiver() {
                            await send(._internal(.caregiverLoaded(caregiver)))
                        }
                    }
                    .cancellable(id: CancelID.caregiverStream, cancelInFlight: true)
                )

            case let ._internal(.babiesLoaded(babies)):
                state.babies = IdentifiedArray(uniqueElements: babies)
                state.settings.babies = state.babies
                state.home.babies = state.babies
                propagateSelectedBaby(into: &state)
                return .none

            case let ._internal(.caregiverLoaded(caregiver)):
                guard let caregiver else { return .none }
                state.caregiver = caregiver
                state.settings.caregiver = caregiver
                return .none
            }
        }
    }
}

public extension MainTabFeature {
    enum Tab: Hashable, Sendable {
        case home
        case note
        case cryAnalysis
        case statistic
        case settings
    }
}
