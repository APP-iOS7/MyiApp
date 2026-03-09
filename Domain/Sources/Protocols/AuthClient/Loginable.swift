import Foundation

/// 주어진 로그인 제공자(LoginProvider)를 사용해 사용자를 인증할 수 있는 능력을 정의하는 프로토콜입니다.
///
/// `Loginable`을 채택한 타입은 `login(provider:)` 메서드를 구현하여
/// 지정된 `LoginProvider`를 통해 비동기 인증 흐름을 수행하고,
/// 성공 시 인증된 `User`를 반환해야 합니다.
///
/// 동시성:
/// - 이 API는 `async`로, 네트워크 또는 시스템 인증 과정에서 일시 중단될 수 있습니다.
/// - 인증 실패, 취소, 검증 오류 등을 전달하기 위해 `throws`를 사용합니다.
///
/// 기대 동작:
/// - 구현체는 제공된 제공자 정보를 바탕으로 자격 증명(토큰, 아이디/비밀번호 등)을 검증해야 합니다.
/// - 성공 시 완전히 초기화된 `User`를 반환합니다.
/// - 실패 시 적절한 오류(예: 잘못된 자격 증명, 네트워크 문제, 사용자 취소)를 던집니다.
///
/// - Note: 실제 동작과 지원되는 제공자 유형은 구체 구현에 따라 달라집니다.
///         제공자별 요구사항(스코프, 권한, 콜백 URL 등)을 문서화하는 것을 권장합니다.
///
/// - Parameters:
///   - provider: 인증 방식을 정의하는 `LoginProvider` (예: OAuth, SSO, 이메일/비밀번호).
///
/// - Returns: 인증에 성공한 `User`.
///
/// - Throws: 인증 실패, 사용자 취소, 또는 인증을 완료할 수 없는 경우의 오류를 던집니다.
public protocol Loginable: Sendable {
    func login(provider: LoginProvider) async throws -> User
}
