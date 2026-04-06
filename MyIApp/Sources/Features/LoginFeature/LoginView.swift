import ComposableArchitecture
import SwiftUI

struct LoginView: View {
    let store: StoreOf<LoginFeature>

    var body: some View {
        VStack(spacing: 16) {
            Button("Apple로 로그인") {
                store.send(.view(.appleSignInButtonTapped))
            }

            Button("Google로 로그인") {
                store.send(.view(.googleSignInButtonTapped))
            }
        }
        .disabled(store.isLoading)
    }
}
