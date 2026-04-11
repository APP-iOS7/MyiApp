import Foundation

public struct NewBabyRequest: Equatable, Sendable {
    public let name: String
    public let gender: Gender
    public let birthDate: Date
    public let isTimeSelectionEnabled: Bool
    public let height: Double
    public let weight: Double
    public let bloodType: BloodType

    public init(
        name: String,
        gender: Gender,
        birthDate: Date,
        isTimeSelectionEnabled: Bool,
        height: Double,
        weight: Double,
        bloodType: BloodType
    ) {
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.isTimeSelectionEnabled = isTimeSelectionEnabled
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
    }
}
