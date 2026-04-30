import ComposableArchitecture
import Domain
import Features

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var phase: Phase = .launching
        public var auth: LoginFeature.State = .init()
        public var session: Session?
        @Presents public var destination: Destination.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case sessionUpdated(Session?)
        case babiesFetched([Baby])
        case babiesFetchFailed(BabyError)
        case auth(LoginFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.babyClient) var babyClient
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
                    state.destination = nil
                    return .none
                }
                return .run { [babyClient] send in
                    do throws(BabyError) {
                        let babies = try await babyClient.currentBabies()
                        await send(.babiesFetched(babies))
                    } catch {
                        await send(.babiesFetchFailed(error))
                    }
                }

            case let .babiesFetched(babies):
                guard let session = state.session else { return .none }
                state.phase = .running
                guard let tabState = MainTabFeature.State(session: session, babies: babies) else {
                    state.destination = .babyRegister(BabyRegisterFeature.State())
                    return .none
                }
                if case var .mainTab(existing) = state.destination {
                    existing.babies = tabState.babies
                    state.destination = .mainTab(existing)
                } else {
                    state.destination = .mainTab(tabState)
                }
                return .none

            case .babiesFetchFailed:
                guard state.session != nil else { return .none }
                state.phase = .running
                if state.destination == nil {
                    state.destination = .babyRegister(BabyRegisterFeature.State())
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
}

extension AppFeature {
    public enum Phase: Equatable, Sendable {
        case launching
        case running
    }

    @Reducer
    public enum Destination {
        case mainTab(MainTabFeature)
        case babyRegister(BabyRegisterFeature)
    }
}

extension AppFeature.Destination.State: Equatable {}
