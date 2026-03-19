import Foundation

/// 보호자(Caregiver) 역할을 정의하는 도메인 모델입니다.
/// 시스템 사용자인 `User`가 특정 가족/아기 그룹 내에서 가지는 역할을 나타냅니다.
public struct Caregiver: Sendable, Identifiable {
    public let id: String
    public let name: String
    public let email: String
    public var role: String? // 예: 엄마, 아빠, 할머니 등 (자유 입력 또는 확장 가능)
    public var lastSelectedBabyID: String?

    public init(
        id: String,
        name: String,
        email: String,
        role: String? = nil,
        lastSelectedBabyID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.lastSelectedBabyID = lastSelectedBabyID
    }
}
