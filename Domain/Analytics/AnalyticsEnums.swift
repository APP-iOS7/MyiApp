import Foundation

public enum BabyAgeBucket: String, Sendable, Equatable {
    case zeroToThree = "0-3"
    case fourToSix = "4-6"
    case sevenToTwelve = "7-12"
    case thirteenToTwentyFour = "13-24"
    case twentyFivePlus = "25+"

    public init(monthsOld: Int) {
        switch monthsOld {
        case ..<4: self = .zeroToThree
        case 4 ... 6: self = .fourToSix
        case 7 ... 12: self = .sevenToTwelve
        case 13 ... 24: self = .thirteenToTwentyFour
        default: self = .twentyFivePlus
        }
    }
}

public enum AnalyticsAuthProvider: String, Sendable, Equatable {
    case apple
    case google
    case unknown

    public init(providerIDs: [String]) {
        if providerIDs.contains("apple.com") {
            self = .apple
        } else if providerIDs.contains("google.com") {
            self = .google
        } else {
            self = .unknown
        }
    }
}

public enum StatisticPeriod: String, Sendable, Equatable {
    case day
    case week
    case month
}
