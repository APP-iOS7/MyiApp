import Foundation

public enum EmotionType: String, Codable, Sendable, CaseIterable, Hashable {
    case bellyPain = "belly_pain"
    case burping
    case coldHot = "cold_hot"
    case hungry
    case lonely
    case scared
    case tired
    case unknown
}

extension EmotionType {
    public var displayName: String {
        switch self {
        case .bellyPain: "배가 아파요"
        case .burping:   "트림하고 싶어요"
        case .coldHot:   "춥거나 더워요"
        case .hungry:    "배고파요"
        case .lonely:    "외로워요"
        case .scared:    "무서워요"
        case .tired:     "졸려요"
        case .unknown:   "분석 불가"
        }
    }
}
