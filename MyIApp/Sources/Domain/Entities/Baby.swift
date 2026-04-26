import Foundation

public struct Baby: Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let gender: Gender
    public let birthDate: Date
    public let height: Double
    public let weight: Double
    public let bloodType: BloodType
    public let photoURL: String?
    public let mainCaregiver: String
    public let caregivers: [String]

    public init(
        id: String,
        name: String,
        gender: Gender,
        birthDate: Date,
        height: Double,
        weight: Double,
        bloodType: BloodType,
        photoURL: String? = nil,
        mainCaregiver: String,
        caregivers: [String] = []
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.photoURL = photoURL
        self.mainCaregiver = mainCaregiver
        self.caregivers = caregivers
    }
}
