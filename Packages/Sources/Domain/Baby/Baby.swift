import Foundation

public struct Baby: Identifiable, Hashable, Sendable {
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
