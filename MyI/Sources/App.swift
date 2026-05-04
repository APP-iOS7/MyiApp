import ComposableArchitecture
import Features
import Shared
import SwiftUI

@main
struct MyIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    private let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if store.phase == .launching {
                    LaunchScreenView()
                        .ignoresSafeArea()
                } else if let destinationStore = store.scope(state: \.destination, action: \.destination.presented) {
                    switch destinationStore.case {
                    case let .mainTab(tabStore):
                        MainTabView(store: tabStore)
                    case let .babyRegister(registerStore):
                        BabyRegisterFlowView(store: registerStore)
                    }
                } else {
                    LoginView(store: store.scope(state: \.auth, action: \.auth))
                }
            }
            .onAppear { store.send(.onAppear) }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                Task { await ImageCache.shared.trimDisk() }
            }
        }
    }
}
