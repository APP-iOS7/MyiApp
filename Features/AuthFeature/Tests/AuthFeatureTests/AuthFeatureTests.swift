import AuthFeature
import AuthFeatureTesting
import ComposableArchitecture
import Core
import Domain
import Foundation
import Testing

@MainActor
struct LoginFeatureTests {
    @Test("Google 로그인 성공 테스트")
    func googleLoginSuccessTest() async {
        let mockUser = AuthFeatureTesting.mockUser
        let store = TestStore(initialState: AuthFeature.LoginFeature.State()) {
            AuthFeature.LoginFeature()
        } withDependencies: {
            $0.authClient.login = { provider throws(AuthError) in
                #expect(provider == .google)
                return mockUser as Domain.User
            }
        }

        // 로그인 버튼 탭
        await store.send(.loginButtonTapped(.google)) {
            $0.isLoading = true
            $0.error = nil
        }

        // 로그인 결과 수신 및 상태 업데이트 확인
        await store.receive(\.loginResponse.success) {
            $0.isLoading = false
            $0.currentUser = mockUser as Domain.User
        }
    }

    @Test("로그인 실패 테스트")
    func googleLoginFailureTest() async {
        let error = AuthError.invalidCredentials
        let store = TestStore(initialState: AuthFeature.LoginFeature.State()) {
            AuthFeature.LoginFeature()
        } withDependencies: {
            $0.authClient.login = { _ throws(AuthError) in
                throw error
            }
        }

        await store.send(.loginButtonTapped(.google)) {
            $0.isLoading = true
        }

        await store.receive(\.loginResponse.failure) {
            $0.isLoading = false
            $0.error = error.localizedDescription
        }
    }

    @Test("Apple 로그인 성공 테스트")
    func appleLoginSuccessTest() async {
        let mockUser = User(
            id: "apple-user-id",
            email: "apple@test.com",
            name: "Apple User",
            imageURL: nil,
            createdAt: Date(),
            updatedAt: Date(),
            loginProvider: .apple
        )
        let store = TestStore(initialState: AuthFeature.LoginFeature.State()) {
            AuthFeature.LoginFeature()
        } withDependencies: {
            $0.authClient.login = { provider throws(AuthError) in
                #expect(provider == .apple)
                return mockUser as Domain.User
            }
        }

        await store.send(.loginButtonTapped(.apple)) {
            $0.isLoading = true
        }

        await store.receive(\.loginResponse.success) {
            $0.isLoading = false
            $0.currentUser = mockUser
        }
    }
}
