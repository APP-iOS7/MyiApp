import Foundation

/// 아기(Baby) 정보를 정의하는 도메인 모델입니다.
public struct Baby: Sendable, Identifiable {
    public let id: String
    public var name: String
    public var birthDate: Date
    public var gender: Gender
    public var bloodType: BloodType?
    public var imageURL: URL?

    public init(
        id: String,
        name: String,
        birthDate: Date,
        gender: Gender,
        bloodType: BloodType? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.bloodType = bloodType
        self.imageURL = imageURL
    }
}
