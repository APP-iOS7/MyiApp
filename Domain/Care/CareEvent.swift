import Foundation

public enum CareEvent: Hashable, Sendable, Codable {
    case formula(ml: Int)
    case babyFood(ml: Int)
    case pumpedMilk(ml: Int)
    case breastfeeding(leftMinutes: Int, rightMinutes: Int)
    case pee
    case poop
    case pottyAll
    case sleep(start: Date, end: Date?)
    case bath
    case snack
    case temperature(celsius: Double)
    case medicine
    case clinic
}

extension CareEvent {
    public enum Category: String, CaseIterable, Hashable, Sendable {
        case feeding        // formula/babyFood/pumpedMilk/breastfeeding
        case potty          // pee/poop/pottyAll
        case sleep
        case bath
        case snack
        case vital          // temperature
        case medical        // medicine/clinic
    }

    public var category: Category {
        switch self {
        case .formula, .babyFood, .pumpedMilk, .breastfeeding:  .feeding
        case .pee, .poop, .pottyAll:                            .potty
        case .sleep:                                            .sleep
        case .bath:                                             .bath
        case .snack:                                            .snack
        case .temperature:                                      .vital
        case .medicine, .clinic:                                .medical
        }
    }
}
