import ComposableArchitecture
import Features
import SwiftUI

@main
struct MyIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
                        RegisterMethodPickerView(store: registerStore)
                    }
                } else {
                    LoginView(store: store.scope(state: \.auth, action: \.auth))
                }
            }
            .onAppear { store.send(.onAppear) }
        }
    }
}
