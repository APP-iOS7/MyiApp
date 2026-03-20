import AuthenticationServices
import ComposableArchitecture
import Core
import DesignSystem
import Domain
import SwiftUI

@Reducer
public struct AuthFeature {
    @ObservableState
    @CasePathable
    public enum State: Equatable {
        case login(LoginFeature.State)
        case registerBaby(RegisterBabyFeature.State)

        public init() {
            self = .login(LoginFeature.State())
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case login(LoginFeature.Action)
        case registerBaby(RegisterBabyFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .login, .registerBaby:
                .none
            }
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifCaseLet(\.registerBaby, action: \.registerBaby) {
            RegisterBabyFeature()
        }
    }
}

// MARK: - Features

extension AuthFeature {
    @Reducer
    public struct LoginFeature {
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
                            let user = try await authClient.login(provider)
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

    @Reducer
    public struct RegisterBabyFeature {
        @ObservableState
        public struct State: Equatable {
            public var name: String = ""
            public var birthDate: Date = .init()
            public var gender: Gender = .unknown
            public var isLoading: Bool = false
            public var error: String?

            public init() {}
        }

        public enum Action: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case registerButtonTapped
            case registrationResponse(Result<Bool, CaregiverError>)
            case delegate(Delegate)

            public enum Delegate: Equatable {
                case registered
            }
        }

        @Dependency(\.caregiverClient)
        var caregiverClient
        @Dependency(\.authClient)
        var authClient

        public init() {}

        public var body: some ReducerOf<Self> {
            BindingReducer()
            Reduce { state, action in
                switch action {
                case .binding:
                    return .none

                case .registerButtonTapped:
                    guard !state.name.isEmpty else {
                        state.error = "아기 이름을 입력해주세요."
                        return .none
                    }

                    state.isLoading = true
                    state.error = nil

                    let babyName = state.name
                    let babyBirthDate = state.birthDate
                    let babyGender = state.gender

                    return .run { send in
                        do {
                            guard let user = try await authClient.currentUser() else {
                                await send(.registrationResponse(.failure(.unauthorized)))
                                return
                            }

                            let baby = Baby(
                                id: UUID().uuidString,
                                name: babyName,
                                birthDate: babyBirthDate,
                                gender: babyGender
                            )

                            try await caregiverClient.registerBaby(user.id, baby)
                            await send(.registrationResponse(.success(true)))
                        } catch {
                            let caregiverError = (error as? CaregiverError) ?? .internalError(error)
                            await send(.registrationResponse(.failure(caregiverError)))
                        }
                    }

                case .registrationResponse(.success):
                    state.isLoading = false
                    return .send(.delegate(.registered))

                case let .registrationResponse(.failure(error)):
                    state.isLoading = false
                    state.error = error.localizedDescription
                    return .none

                case .delegate:
                    return .none
                }
            }
        }
    }
}

// MARK: - Views

public struct AuthView: View {
    public let store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        switch store.state {
        case .login:
            if let loginStore = store.scope(state: \.login, action: \.login) {
                LoginView(store: loginStore)
            }

        case .registerBaby:
            if let registerBabyStore = store.scope(state: \.registerBaby, action: \.registerBaby) {
                RegisterBabyView(store: registerBabyStore)
            }
        }
    }
}

public struct LoginView: View {
    @Bindable
    var store: StoreOf<AuthFeature.LoginFeature>

    public init(store: StoreOf<AuthFeature.LoginFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                Text(store.title)
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Colors.launchScreenText)
                    .fontDesign(.rounded)
                    .padding(.horizontal)
                    .padding(.top, 100)

                Text(store.subtitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Colors.launchScreenText)
                    .padding(.bottom, 30)

                Image(DesignSystem.Icons.launchScreenImage, bundle: DesignSystem.bundle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 431, height: 431)
                    .offset(y: -1)

                Spacer()

                VStack(spacing: 16) {
                    Button {
                        store.send(.loginButtonTapped(.google))
                    } label: {
                        HStack {
                            Image(DesignSystem.Icons.googleLogo, bundle: DesignSystem.bundle)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(store.googleLoginButtonTitle)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    }

                    Button {
                        store.send(.loginButtonTapped(.apple))
                    } label: {
                        HStack {
                            Image(systemName: "applelogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text(store.appleLoginButtonTitle)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }

            if store.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .background(DesignSystem.Colors.launchScreen)
        .ignoresSafeArea()
    }
}

public struct RegisterBabyView: View {
    @Bindable
    var store: StoreOf<AuthFeature.RegisterBabyFeature>

    public init(store: StoreOf<AuthFeature.RegisterBabyFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("아기 정보") {
                    TextField("이름", text: $store.name)
                    DatePicker("생년월일", selection: $store.birthDate, displayedComponents: .date)
                    Picker("성별", selection: $store.gender) {
                        Text("선택 안 함").tag(Gender.unknown)
                        Text("남아").tag(Gender.male)
                        Text("여아").tag(Gender.female)
                    }
                }

                if let error = store.error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        store.send(.registerButtonTapped)
                    } label: {
                        if store.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("등록하기")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(store.isLoading)
                }
            }
            .navigationTitle("아기 등록")
        }
    }
}
