import Foundation

public struct Baby: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var name: String
    public var birthDate: Date
    public var gender: Gender
    public var bloodType: BloodType
    public var profileImageURL: URL?
    public var mainCaregiverID: String
    public var caregiverIDs: [String]

    public init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        gender: Gender,
        bloodType: BloodType,
        profileImageURL: URL? = nil,
        mainCaregiverID: String,
        caregiverIDs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.bloodType = bloodType
        self.profileImageURL = profileImageURL
        self.mainCaregiverID = mainCaregiverID
        self.caregiverIDs = caregiverIDs
    }
}

extension Baby {
    /// 주어진 날짜 기준 "X개월 Y일" 형태의 나이 텍스트.
    public func ageText(at date: Date = Date()) -> String {
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: birthDate, to: date).month ?? 0
        let monthDate = calendar.date(byAdding: .month, value: months, to: birthDate) ?? date
        let days = (calendar.dateComponents([.day], from: monthDate, to: date).day ?? 0) + 1
        return "\(months)개월 \(days)일"
    }

    public var developmentalStage: String {
        let components = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let months = components.month ?? 0
        let days = components.day ?? 0

        if months == 0, days < 30 { return "신생아기" }
        if months < 12 { return "영아기" }
        if months < 36 { return "유아기" }
        return "아동기"
    }
}
