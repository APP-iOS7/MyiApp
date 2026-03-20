import Testing
@testable import Domain

struct LoginProviderTests {
    @Test("모든 케이스가 존재하는지 확인")
    func allCasesExist() {
        #expect(LoginProvider.allCases.count >= 2)
    }
}
