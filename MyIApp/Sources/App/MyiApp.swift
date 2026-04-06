import ComposableArchitecture
import SwiftUI

@main
struct MyiApp: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            GateView(store: store.scope(state: \.gate, action: \.gate))
        }
    }
}
