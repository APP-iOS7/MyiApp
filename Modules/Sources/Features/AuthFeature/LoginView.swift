import Clients
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct LoginView: View {
    @Bindable var store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.l) {
            Spacer()

            VStack(spacing: Spacing.s) {
                Text("My i")
                    .font(.Style.brandTitle)

                Text("쉽고 편한 육아 기록 앱")
                    .font(.title2.weight(.semibold))
            }
            .foregroundColor(.Semantic.launchText)

            Image.Brand.mascot
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)

            VStack(spacing: Spacing.m) {
                GoogleSignInButton { store.send(.signInWithGoogleTapped) }
                AppleSignInButton { store.send(.signInWithAppleTapped) }
            }
            .padding(.horizontal, Spacing.l)

            Spacer()
        }
        .background(Color.Semantic.launchBackground.ignoresSafeArea())
        .loadingOverlay(isPresented: store.isLoading)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    LoginView(
        store: Store(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient = .previewValue
        }
    )
}
