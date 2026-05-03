import Foundation

public struct CareRecord: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var createdAt: Date
    public var event: CareEvent
    public var content: String?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        event: CareEvent,
        content: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.event = event
        self.content = content
    }
}

extension Array where Element == CareRecord {
    public func filtered(on date: Date, calendar: Calendar = .current) -> [CareRecord] {
        filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }

    public func filtered(in range: Range<Date>) -> [CareRecord] {
        filter { range.contains($0.createdAt) }
    }

    public func count(of category: CareEvent.Category) -> Int {
        filter { $0.event.category == category }.count
    }

    public var totalMl: Int {
        reduce(0) { total, record in
            switch record.event {
            case let .formula(ml), let .babyFood(ml), let .pumpedMilk(ml): return total + ml
            default: return total
            }
        }
    }

    public var totalBreastfeedingMinutes: Int {
        reduce(0) { total, record in
            if case let .breastfeeding(left, right) = record.event { return total + left + right }
            return total
        }
    }

    public var pottyCount: (pee: Int, poop: Int) {
        var pee = 0, poop = 0
        for record in self {
            switch record.event {
            case .pee: pee += 1
            case .poop: poop += 1
            case .pottyAll: pee += 1; poop += 1
            default: break
            }
        }
        return (pee, poop)
    }
}

#if DEBUG
extension CareRecord {
    public static let mocks: [CareRecord] = {
        let now = Date()
        let cal = Calendar.current
        return [
            CareRecord(createdAt: cal.date(byAdding: .hour, value: -5, to: now)!, event: .formula(ml: 120)),
            CareRecord(createdAt: cal.date(byAdding: .hour, value: -4, to: now)!, event: .breastfeeding(leftMinutes: 10, rightMinutes: 8)),
            CareRecord(createdAt: cal.date(byAdding: .hour, value: -3, to: now)!, event: .pee),
            CareRecord(createdAt: cal.date(byAdding: .hour, value: -2, to: now)!, event: .sleep(start: cal.date(byAdding: .hour, value: -4, to: now)!, end: cal.date(byAdding: .hour, value: -2, to: now)!)),
            CareRecord(createdAt: cal.date(byAdding: .hour, value: -1, to: now)!, event: .temperature(celsius: 36.5)),
            CareRecord(createdAt: now, event: .bath, content: "목욕 완료"),
        ]
    }()
}
#endif
