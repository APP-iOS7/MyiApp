import ComposableArchitecture
import Domain
import Features
import Foundation

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var phase: Phase = .launching
        public var auth: LoginFeature.State = .init()
        public var session: Session?
        public var pendingCaregiver: Caregiver?
        public var pendingBabies: [Baby]?
        @Presents public var destination: Destination.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case sessionUpdated(Session?)
        case caregiverFetched(Caregiver?)
        case babiesFetched([Baby])
        case babiesFetchFailed(BabyError)
        case auth(LoginFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.babyClient) var babyClient
    @Dependency(\.caregiverClient) var caregiverClient
    @Dependency(\.localNotificationClient) var localNotificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            LoginFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { [authClient] send in
                        for await session in authClient.stateStream() {
                            await send(.sessionUpdated(session))
                        }
                    },
                    .run { [localNotificationClient] _ in
                        _ = await localNotificationClient.requestPermission()
                    }
                )

            case let .sessionUpdated(session):
                state.session = session
                guard session != nil else {
                    state.phase = .running
                    state.pendingCaregiver = nil
                    state.pendingBabies = nil
                    state.destination = nil
                    return .none
                }
                state.pendingCaregiver = nil
                state.pendingBabies = nil
                return .merge(
                    .run { [caregiverClient] send in
                        try? await caregiverClient.provisionCaregiver()
                        let caregiver = try? await caregiverClient.currentCaregiver()
                        await send(.caregiverFetched(caregiver))
                    },
                    .run { [babyClient] send in
                        do throws(BabyError) {
                            let babies = try await babyClient.currentBabies()
                            await send(.babiesFetched(babies))
                        } catch {
                            await send(.babiesFetchFailed(error))
                        }
                    }
                )

            case let .caregiverFetched(caregiver):
                state.pendingCaregiver = caregiver
                return tryEnterMainTab(&state)

            case let .babiesFetched(babies):
                state.pendingBabies = babies
                return tryEnterMainTab(&state)

            case .babiesFetchFailed:
                guard state.session != nil else { return .none }
                state.phase = .running
                if state.destination == nil {
                    state.destination = .babyRegister(BabyRegisterFlowFeature.State())
                }
                return .none

            case .destination(.presented(.babyRegister(.delegate(.babyRegistered)))):
                guard state.session != nil else { return .none }
                return .run { [babyClient] send in
                    do throws(BabyError) {
                        let babies = try await babyClient.currentBabies()
                        await send(.babiesFetched(babies))
                    } catch {
                        await send(.babiesFetchFailed(error))
                    }
                }

            case .auth, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func tryEnterMainTab(_ state: inout State) -> Effect<Action> {
        guard let session = state.session,
              let caregiver = state.pendingCaregiver,
              let babies = state.pendingBabies else {
            return .none
        }
        state.phase = .running
        guard let tabState = MainTabFeature.State(session: session, caregiver: caregiver, babies: babies) else {
            state.destination = .babyRegister(BabyRegisterFlowFeature.State())
            return .none
        }
        if case var .mainTab(existing) = state.destination {
            existing.babies = tabState.babies
            existing.caregiver = tabState.caregiver
            state.destination = .mainTab(existing)
        } else {
            state.destination = .mainTab(tabState)
        }
        return .none
    }
}

extension AppFeature {
    public enum Phase: Equatable, Sendable {
        case launching
        case running
    }

    @Reducer
    public enum Destination {
        case mainTab(MainTabFeature)
        case babyRegister(BabyRegisterFlowFeature)
    }
}

extension AppFeature.Destination.State: Equatable {}
