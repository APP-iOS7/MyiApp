import AuthFeature
import ComposableArchitecture
import SwiftUI

@main
struct AuthFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AuthView(
                store: Store(initialState: AuthFeature.State()) {
                    AuthFeature()
                }
            )
        }
    }
}
