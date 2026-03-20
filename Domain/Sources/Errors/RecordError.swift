import Foundation

/// 기록(수유, 기저귀 등) 관련 작업 중 발생할 수 있는 오류를 정의합니다.
public enum RecordError: Error, Equatable, Sendable {
    /// 해당 기록을 찾을 수 없음
    case notFound
    /// 권한 없음
    case unauthorized
    /// 잘못된 데이터 형식
    case invalidData
    /// 네트워크 또는 데이터베이스 내부 오류
    case internalError(Error?)

    public var localizedDescription: String {
        switch self {
        case .notFound: "기록을 찾을 수 없습니다."
        case .unauthorized: "권한이 없습니다."
        case .invalidData: "잘못된 데이터 형식입니다."
        case let .internalError(error): "내부 오류가 발생했습니다: \(error?.localizedDescription ?? "알 수 없음")"
        }
    }

    public static func == (lhs: RecordError, rhs: RecordError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound),
             (.unauthorized, .unauthorized),
             (.invalidData, .invalidData):
            true
        case (.internalError, .internalError):
            true
        default:
            false
        }
    }
}
