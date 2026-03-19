import FirebaseAuth
import FirebaseCore
import XCTest
@testable import Core
@testable import Domain

final class AuthClientLiveTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        if FirebaseApp.app() == nil {
            // 목업 또는 에뮬레이터 용도 파이어베이스 환경 세팅
            // FirebaseOptions를 매뉴얼하게 줘서 configure
            let options = FirebaseOptions(
                googleAppID: "1:1234567890:ios:321abc456def7890",
                gcmSenderID: "1234567890"
            )
            options.projectID = "demo-myiapp"
            options.apiKey = "AIzaSyDummyKey123456789"
            FirebaseApp.configure(options: options)
        }
    }

    override func setUp() {
        super.setUp()
        // 매 테스트마다 에뮬레이터 사용 (한 번만 세팅 가능하므로 에러 무시용 try? 또는 최초 세팅 반영)
        // Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
        // 실제로는 에뮬레이터 세팅이 앱 라이프사이클 1회만 가능할 수 있으므로 분기 필요.
        let auth = Auth.auth()
        let isEmulatorConfigured = auth.settings?.isAppVerificationDisabledForTesting ?? false
        if !isEmulatorConfigured {
            auth.useEmulator(withHost: "127.0.0.1", port: 9099)
            auth.settings?.isAppVerificationDisabledForTesting = true
        }
    }

    override func tearDown() async throws {
        // 테스트 종료 시 로그아웃
        try? Auth.auth().signOut()
        try await super.tearDown()
    }

    func test_Given_초기상태_When_currentUser호출시_Then_nil반환() async throws {
        // Given
        let client = AuthClient.liveValue

        // When
        let user = try await client.currentUser()

        // Then
        XCTAssertNil(user, "초기 상태(에뮬레이터)에서 로그인된 유저는 nil이어야 합니다.")
    }

    func test_Given_에뮬레이터환경_When_로그아웃호출시_Then_에러없음() async throws {
        // Given
        let client = AuthClient.liveValue

        // When / Then
        do {
            try await client.logout()
            XCTAssertTrue(true)
        } catch {
            XCTFail("로그아웃 호출 시 에러가 발생해서는 안 됩니다: \(error)")
        }
    }
}
