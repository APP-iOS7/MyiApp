import Domain
import Foundation

extension CaregiverClient {
    public static var mock: Self {
        Self(
            fetchCaregiver: { _ throws(CaregiverError) in .mock },
            registerCaregiver: { _ throws(CaregiverError) in },
            connectCaregiver: { _, _ throws(CaregiverError) in }
        )
    }

    public static func failing(error: CaregiverError) -> Self {
        Self(
            fetchCaregiver: { _ throws(CaregiverError) in throw error },
            registerCaregiver: { _ throws(CaregiverError) in throw error },
            connectCaregiver: { _, _ throws(CaregiverError) in throw error }
        )
    }
}

extension Caregiver {
    public static var mock: Self {
        Caregiver(
            id: "mock_id",
            name: "테스트 보호자",
            email: "test@example.com",
            role: "엄마"
        )
    }
}
