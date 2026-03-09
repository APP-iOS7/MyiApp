import XCTest

@testable import Domain

final class LoginProviderTests: XCTestCase {
    func test_cases_exist() {
        let _: LoginProvider = .google
        let _: LoginProvider = .apple
    }
}
