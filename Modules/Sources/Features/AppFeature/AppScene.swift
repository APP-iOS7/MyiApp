import Clients
import ComposableArchitecture
import SwiftUI

public struct AppScene: Scene {
    @State private var store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    public init() {
        AppBootstrap.configure()
    }

    public var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL { _ = AppBootstrap.handle(url: $0) }
        }
    }
}
