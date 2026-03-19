import Foundation

/// 보호자 및 아기 관련 작업 중 발생할 수 있는 오류를 정의합니다.
public enum CaregiverError: Error, Sendable {
    /// 해당 정보를 찾을 수 없음
    case notFound
    /// 권한 없음
    case unauthorized
    /// 이미 등록된 정보
    case alreadyExists
    /// 잘못된 상호작용 (예: 자기 자신을 연결 등)
    case invalidInteraction
    /// 네트워크 또는 데이터베이스 내부 오류
    case internalError(Error?)

    public var localizedDescription: String {
        switch self {
        case .notFound: "정보를 찾을 수 없습니다."
        case .unauthorized: "권한이 없습니다."
        case .alreadyExists: "이미 등록된 정보입니다."
        case .invalidInteraction: "잘못된 요청입니다."
        case let .internalError(error): "내부 오류가 발생했습니다: \(error?.localizedDescription ?? "알 수 없음")"
        }
    }
}
