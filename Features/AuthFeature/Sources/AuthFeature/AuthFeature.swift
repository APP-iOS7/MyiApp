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

            case .loginResponse(.success):
                state.isLoading = false
                // TODO: 로그인 성공 후 후속 처리 (홈 이동 등)
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
        VStack(spacing: 30) {
            Spacer()

            // 로고 (Asset 추가 전까지 아이콘으로 대체)
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.pink)

            VStack(spacing: 8) {
                Text("마이 아이")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("아기 울음 분석 & 성장 기록")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if self.store.isLoading {
                ProgressView()
            } else {
                VStack(spacing: 12) {
                    Button {
                        self.store.send(.loginButtonTapped(.google))
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Google로 시작하기")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.black.opacity(0.1), lineWidth: 1)
                        }
                    }

                    // 추가 로그인 수단 (애플 등) 확장 예정
                }
                .padding(.horizontal, 40)
            }

            if let error = store.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
    }
}
