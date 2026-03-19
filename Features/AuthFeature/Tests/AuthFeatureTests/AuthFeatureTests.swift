import AuthFeature
import AuthFeatureTesting
import ComposableArchitecture
import Core
import Domain
import XCTest

@MainActor
final class AuthFeatureTests: XCTestCase {
    func test_Given_초기상태_When_로그인버튼탭시_Then_로딩상태로진입함() async {
        let store = TestStore(initialState: AuthFeature.State()) {
            AuthFeature()
        } withDependencies: {
            $0.authClient.login = { _ in AuthFeatureTesting.mockUser }
        }

        await store.send(.loginButtonTapped(.google)) {
            $0.isLoading = true
        }

        await store.receive(.loginResponse(.success(AuthFeatureTesting.mockUser))) {
            $0.isLoading = false
        }
    }
}
