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
