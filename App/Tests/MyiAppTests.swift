import Testing
@testable import MyiApp

struct MyiAppTests {
    @Test("App 모듈 테스트 가능 여부 확인")
    func appModuleTestability() {
        #expect(true)
    }
}
