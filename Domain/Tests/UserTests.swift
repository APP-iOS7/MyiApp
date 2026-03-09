import XCTest

@testable import Domain

final class UserTests: XCTestCase {
    func test_init_setsPropertiesCorrectly() {
        let date = Date()
        let user = User(
            id: "user-1",
            email: "test@example.com",
            name: "테스트",
            imageURL: nil,
            createdAt: date,
            updatedAt: date,
            loginProvider: .google
        )

        XCTAssertEqual(user.id, "user-1")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.name, "테스트")
        XCTAssertNil(user.imageURL)
        XCTAssertEqual(user.createdAt, date)
        XCTAssertEqual(user.updatedAt, date)
        XCTAssertEqual(user.loginProvider, .google)
    }
}
