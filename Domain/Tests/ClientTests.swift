import Foundation
import Testing
@testable import Domain

struct ClientTests {
    private actor AuthMockState {
        var isLoginCalled = false
        func setIsLoginCalled(_ value: Bool) {
            self.isLoginCalled = value
        }
    }

    @Test("AuthClient 가 정상적으로 동작하는지 확인")
    func authClientFunctionsNormally() async throws {
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

        let state = AuthMockState()
        let client = AuthClient(
            currentUser: { () throws(AuthError) in nil },
            login: { _ throws(AuthError) in
                await state.setIsLoginCalled(true)
                return mockUser
            },
            logout: { () throws(AuthError) in },
            deleteAccount: { () throws(AuthError) in }
        )

        // When
        let user = try await client.login(.google)

        // Then
        let isLoginCalled = await state.isLoginCalled
        #expect(isLoginCalled == true)
        #expect(user.id == "user-1")
    }

    private actor RecordMockState {
        var savedRecord: Record?
        func setSavedRecord(_ record: Record) {
            self.savedRecord = record
        }
    }

    @Test("RecordClient 가 정상적으로 동작하는지 확인")
    func recordClientFunctionsNormally() async throws {
        // Given
        let state = RecordMockState()
        let client = RecordClient(
            fetchRecords: { _ throws(RecordError) in [] },
            saveRecord: { record throws(RecordError) in
                await state.setSavedRecord(record)
            },
            deleteRecord: { _ throws(RecordError) in }
        )
        let record = Record(babyID: "baby-1", type: .feeding)

        // When
        try await client.saveRecord(record)

        // Then
        let savedRecord = await state.savedRecord
        #expect(savedRecord?.babyID == "baby-1")
        #expect(savedRecord?.type == .feeding)
    }
}
