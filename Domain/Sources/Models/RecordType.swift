import Foundation

public enum RecordType: String, Codable, Sendable, CaseIterable {
    case cry // 울음 분석
    case diaper // 기저귀
    case feeding // 수유
    case sleep // 수면
    case activity // 활동
    case health // 건강/투약
}
