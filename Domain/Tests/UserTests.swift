import Foundation
import Testing
@testable import Domain

struct UserTests {
    @Test("User 초기화 및 프로퍼티 설정 확인")
    func userInitializationAndPropertySetup() {
        // Given
        let date = Date()

        // When
        let user = User(
            id: "user-1",
            email: "test@example.com",
            name: "테스트",
            imageURL: nil,
            createdAt: date,
            updatedAt: date,
            loginProvider: .google
        )

        // Then
        #expect(user.id == "user-1")
        #expect(user.email == "test@example.com")
        #expect(user.name == "테스트")
        #expect(user.imageURL == nil)
        #expect(user.createdAt == date)
        #expect(user.updatedAt == date)
        #expect(user.loginProvider == .google)
    }
}
