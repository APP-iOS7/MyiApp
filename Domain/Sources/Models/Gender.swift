import Foundation

/// 아기의 성별을 나타내는 모델입니다.
public enum Gender: Int, Sendable, Codable {
    case male = 1
    case female = 2
    case unknown = 0
}
