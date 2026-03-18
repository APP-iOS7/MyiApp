import Foundation

/// 인증 도메인에서 발생할 수 있는 오류를 정의합니다.
///
/// `AuthClient` 프로토콜 구현체(Loginable, Logoutable 등)는
/// 이 타입의 오류를 던지며, 호출자는 `AuthError`로 구체적인 처리가 가능합니다.
///
/// 뷰모델 등에서 사용자에게 메시지를 보여줄 때는 `LocalizedError`의
/// `errorDescription`을 사용하면 됩니다.
public enum AuthError: Error, Sendable, LocalizedError {
    /// 사용자가 로그인/인증 흐름을 취소함
    case cancelled

    /// 잘못된 자격 증명 또는 토큰 검증 실패
    case invalidCredentials

    /// 네트워크 연결 불가 또는 타임아웃
    case networkUnavailable

    /// 세션 만료 또는 토큰 만료
    case sessionExpired

    /// 기타 알 수 없는 오류
    case unknown

    public var errorDescription: String? {
        switch self {
        case .cancelled: "로그인이 취소되었습니다."
        case .invalidCredentials: "인증에 실패했습니다."
        case .networkUnavailable: "네트워크 연결을 확인해 주세요."
        case .sessionExpired: "세션이 만료되었습니다. 다시 로그인해 주세요."
        case .unknown: "오류가 발생했습니다."
        }
    }
}
