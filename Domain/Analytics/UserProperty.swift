import Foundation

public enum UserProperty: Sendable, Equatable {
    case babyCount(Int)
    case hasCaregiver(Bool)
    case babyAgeMonthsBucket(BabyAgeBucket)
    case authProvider(AnalyticsAuthProvider)
}
