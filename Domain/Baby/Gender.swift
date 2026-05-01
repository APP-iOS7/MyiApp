public enum Gender: String, CaseIterable, Sendable, Codable {
    case male
    case female

    public var displayName: String {
        switch self {
        case .male: "남자"
        case .female: "여자"
        }
    }
}
