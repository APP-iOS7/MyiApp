import Clients
import ComposableArchitecture
import DesignSystem
import Features
import SwiftUI

@main
struct MyIApp: App {
    var body: some Scene {
        AppScene()
    }
}

// MARK: - View

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
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

// MARK: - Scene

struct AppScene: Scene {
    @State private var store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    init() {
        AppBootstrap.configure()
        FontRegistrar.register()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL { _ = AppBootstrap.handle(url: $0) }
        }
    }
}
