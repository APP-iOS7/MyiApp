import ComposableArchitecture
import SwiftUI

struct LoginView: View {
    let store: StoreOf<LoginFeature>

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.componentVerticalSpacing) {
            Spacer()

            headerView

            signInButtons

            Spacer()
        }
        .background(DesignSystem.Colors.launchBackground)
        .disabled(store.isLoading)
        .alert(Bindable(store).scope(state: \.alert, action: \.alert))
        .overlay {
            if store.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: DesignSystem.Spacing.componentVerticalSpacing) {
            Text(store.title)
                .font(.system(size: DesignSystem.Typography.headerLogoSize, weight: .bold))
                .foregroundColor(DesignSystem.Colors.launchText)
                .padding(.horizontal, DesignSystem.Spacing.defaultPadding)
                .padding(.top, DesignSystem.Spacing.xxxxLarge)

            Text(store.subtitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.launchText)
                .padding(.bottom, DesignSystem.Spacing.xxxLarge)

            Image(.launchScreen)
                .resizable()
                .scaledToFit()
                .frame(
                    width: DesignSystem.Sizing.illustrationLarge,
                    height: DesignSystem.Sizing.illustrationLarge
                )
        }
    }

    private var signInButtons: some View {
        VStack(spacing: DesignSystem.Spacing.componentVerticalSpacing) {
            SignInButton(
                title: store.googleButtonTitle,
                image: .AuthIcons.icAuthGoogleLogo,
                action: { store.send(.view(.googleSignInButtonTapped)) }
            )

            SignInButton(
                title: store.appleButtonTitle,
                image: .AuthIcons.icAuthAppleLogo,
                action: { store.send(.view(.appleSignInButtonTapped)) }
            )
        }
        .padding(.bottom, DesignSystem.Spacing.xxxxxLarge)
    }

    private var loadingOverlay: some View {
        ZStack {
            DesignSystem.Colors.buttonBorder.opacity(DesignSystem.Animation.overlayOpacity)
                .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(DesignSystem.Animation.loadingScale)
        }
    }
}

#Preview {
    LoginView(
        store: Store(initialState: LoginFeature.State()) {
            LoginFeature()
        }
    )
}
