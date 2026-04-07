import ComposableArchitecture
import Firebase
import SwiftUI

@main
struct MyiApp: App {
    let store: StoreOf<AppFeature>

    init() {
        FirebaseApp.configure()
        store = Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    }

    var body: some Scene {
        WindowGroup {
            GateView(store: store.scope(state: \.gate, action: \.gate))
        }
    }
}
