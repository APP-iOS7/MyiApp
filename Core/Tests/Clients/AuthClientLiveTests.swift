import FirebaseAuth
import FirebaseCore
import Foundation
import Testing
@testable import Core
@testable import Domain

@Suite(.serialized)
struct AuthClientLiveTests {
    init() {
        FirebaseTestEnvironment.shared.setup()
    }

    @Test("초기 상태에서 현재 유저는 nil이어야 함")
    func currentUserIsNilInitially() async throws {
        guard await FirebaseEmulatorCheck.isAuthEmulatorRunning() else {
            return
        }

        // Given
        let client = AuthClient.liveValue

        // 테스트 전 로그아웃 보장
        try? Auth.auth().signOut()

        // When
        let user = try await client.currentUser()

        // Then
        #expect(user == nil, "초기 상태(에뮬레이터)에서 로그인된 유저는 nil이어야 합니다.")
    }

    @Test("로그아웃 호출 시 에러가 발생하지 않음")
    func logoutDoesNotThrowError() async throws {
        guard await FirebaseEmulatorCheck.isAuthEmulatorRunning() else {
            return
        }

        // Given
        let client = AuthClient.liveValue

        // When / Then
        try await client.logout()
        // 성공적으로 실행되면 통과
    }
}
