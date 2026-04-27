import Clients
import ComposableArchitecture
import DesignSystem
import Features
import SwiftUI

@main
struct MyIApp: App {
    private let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        AppBootstrap.configure()
        FontRegistrar.register()
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
                        RegisterMethodPickerView(store: registerStore)
                    }
                } else {
                    LoginView(store: store.scope(state: \.auth, action: \.auth))
                }
            }
            .onAppear { store.send(.onAppear) }
            .onOpenURL { _ = AppBootstrap.handle(url: $0) }
        }
    }
}
