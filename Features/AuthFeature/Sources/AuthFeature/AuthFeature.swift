import AuthenticationServices
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

@Reducer
public struct AuthFeature {
    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var error: String?
        public var currentUser: User?
        public let title: LocalizedStringResource = AuthFeatureStrings.title
        public let subtitle: LocalizedStringResource = AuthFeatureStrings.subtitle
        public let googleLoginButtonTitle: LocalizedStringResource = AuthFeatureStrings.googleLoginButtonTitle
        public let appleLoginButtonTitle: LocalizedStringResource = AuthFeatureStrings.appleLoginButtonTitle

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case loginButtonTapped(LoginProvider)
        case loginResponse(Result<User, AuthError>)
    }

    @Dependency(\.authClient)
    var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case let .loginButtonTapped(provider):
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let user = try await self.authClient.login(provider)
                        await send(.loginResponse(.success(user)))
                    } catch {
                        let authError = (error as? AuthError) ?? .unknown
                        await send(.loginResponse(.failure(authError)))
                    }
                }

            case let .loginResponse(.success(user)):
                state.isLoading = false
                state.currentUser = user
                return .none

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            }
        }
    }
}

public struct AuthView: View {
    @Bindable
    var store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                Text(self.store.title)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Colors.launchScreenText)
                    .fontDesign(.rounded)
                    .padding(.horizontal)
                    .padding(.top, 100)

                Text(self.store.subtitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Colors.launchScreenText)
                    .padding(.bottom, 30)

                Image(DesignSystem.Icons.launchScreenImage, bundle: DesignSystem.bundle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 431, height: 431)
                    .offset(y: -1)

                // Google 로그인 버튼
                Button {
                    self.store.send(.loginButtonTapped(.google))
                } label: {
                    HStack(spacing: 8) {
                        Image(DesignSystem.Icons.googleLogo, bundle: DesignSystem.bundle)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)

                        Text(self.store.googleLoginButtonTitle)
                            .font(.system(size: 18.5, weight: .semibold))
                            .kerning(-0.2)
                            .baselineOffset(0.5)
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.vertical, 13)
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black, lineWidth: 0.8)
                }
                .padding(.horizontal, 50)
                .offset(y: -20)

                // Apple 로그인 버튼
                SignInWithAppleButton(.signIn) { _ in
                    // Apple ID 요청 설정
                } onCompletion: { result in
                    switch result {
                    case .success:
                        self.store.send(.loginButtonTapped(.apple))
                    case let .failure(error):
                        // 에러 처리
                        print(error.localizedDescription)
                    }
                }
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(height: 50)
                .padding(.horizontal, 50)
                .padding(.bottom, 150)

                Spacer()
            }

            if self.store.isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }

            if let error = store.error {
                VStack {
                    Spacer()
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.error)
                        .padding(.bottom, 20)
                }
            }
        }
        .background(DesignSystem.Colors.launchScreen)
        .ignoresSafeArea()
    }
}
