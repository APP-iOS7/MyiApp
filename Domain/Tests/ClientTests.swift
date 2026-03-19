import XCTest

@testable import Domain

final class ClientTests: XCTestCase {
    @MainActor
    func test_Given_AuthClient가있을때_When_Login을호출하면_Then_정상적으로동작함() async throws {
        // Given
        let now = Date()
        let mockUser = User(
            id: "user-1",
            email: "test@test.com",
            name: "홍길동",
            imageURL: nil,
            createdAt: now,
            updatedAt: now,
            loginProvider: .google
        )

        // Swift 6에서 클로저 내 외부 변수 캡처 에러를 피하기 위해 클래스(Reference) 사용
        class State {
            var isLoginCalled = false
        }
        let state = State()

        let client = AuthClient(
            currentUser: { nil },
            login: { _ in
                state.isLoginCalled = true
                return mockUser
            },
            logout: {},
            deleteAccount: {}
        )

        // When
        let user = try await client.login(.google)

        // Then
        XCTAssertTrue(state.isLoginCalled)
        XCTAssertEqual(user.id, "user-1")
    }

    @MainActor
    func test_Given_RecordClient가있을때_When_기록저장을호출하면_Then_정상적으로동작함() async throws {
        // Given
        class State {
            var savedRecord: Record?
        }
        let state = State()

        let client = RecordClient(
            fetchRecords: { _ in [] },
            saveRecord: { record in
                state.savedRecord = record
            },
            deleteRecord: { _ in }
        )
        let record = Record(babyID: "baby-1", type: .feeding)

        // When
        try await client.saveRecord(record)

        // Then
        XCTAssertEqual(state.savedRecord?.babyID, "baby-1")
        XCTAssertEqual(state.savedRecord?.type, .feeding)
    }
}
