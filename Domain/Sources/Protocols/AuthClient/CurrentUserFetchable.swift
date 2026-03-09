import Foundation

/// 현재 로그인된 사용자를 조회할 수 있는 능력을 정의하는 프로토콜입니다.
///
/// 채택한 타입은 `currentUser()` 메서드를 구현하여 현재 인증된 사용자 정보를
/// 비동기적으로 반환합니다. 로그인되어 있지 않으면 `nil`을 반환합니다.
///
/// 동시성:
/// - 조회 작업은 `async`로, 네트워크 또는 로컬 저장소 접근 시 일시 중단될 수 있습니다.
/// - `Sendable`을 상속하므로 구현 타입은 동시성 환경에서 안전하게 사용 가능해야 합니다.
///
/// 반환값:
/// - 로그인된 사용자가 있으면 `User`를 반환합니다.
/// - 로그인되어 있지 않으면 `nil`을 반환합니다.
/// - 네트워크 오류, 토큰 검증 실패 등 예외 상황은 `throws`로 전달합니다.
///
/// 사용 방법:
/// - 앱 진입 시 인증 상태 확인, 프로필 표시, 권한 체크 등에 활용합니다.
/// - 세션 만료 시 `nil`이 반환될 수 있으므로 호출 측에서 적절히 처리하세요.
///
/// 예시:
/// ```swift
/// struct AuthService: CurrentUserFetchable {
///     func currentUser() async throws -> User? {
///         // 토큰 검증 후 User 반환 또는 nil
///     }
/// }
/// ```
public protocol CurrentUserFetchable: Sendable {
    func currentUser() async throws(AuthError) -> User?
}
