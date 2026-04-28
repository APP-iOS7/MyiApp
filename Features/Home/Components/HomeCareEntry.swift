public enum HomeCareEntry: CaseIterable, Hashable, Sendable {
    case feeding
    case potty
    case sleep
    case heightWeight
    case bath
    case snack
    case health
    case memo

    public var label: String {
        switch self {
        case .feeding: "수유/이유식"
        case .potty: "배변"
        case .sleep: "수면"
        case .heightWeight: "키/몸무게"
        case .bath: "목욕"
        case .snack: "간식"
        case .health: "건강 관리"
        case .memo: "메모"
        }
    }
}
