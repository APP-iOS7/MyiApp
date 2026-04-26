import AppFeature
import Clients
import ComposableArchitecture
import SwiftUI

@main
struct MyIApp: App {
    let store: StoreOf<AppFeature>

    init() {
        AppBootstrap.configure()
        store = Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL { url in
                    _ = AppBootstrap.handle(url: url)
                }
        }
    }
}
