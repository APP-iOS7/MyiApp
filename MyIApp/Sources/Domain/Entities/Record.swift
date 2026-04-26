import Foundation

public struct Record: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var createdAt: Date
    public var title: TitleCategory

    /// 분유, 이유식, 유축수유 양 (ml)
    public var mlAmount: Int?

    // 모유수유: 좌/우 분유 수유 시간 (분)
    public var breastfeedingLeftMinutes: Int?
    public var breastfeedingRightMinutes: Int?

    // 수면: 시작 및 종료 시간
    public var sleepStart: Date?
    public var sleepEnd: Date?

    // 키/몸무게
    public var height: Double?
    public var weight: Double?

    /// 온도
    public var temperature: Double?

    /// 텍스트 필드 내용
    public var content: String?

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        title: TitleCategory,
        mlAmount: Int? = nil,
        breastfeedingLeftMinutes: Int? = nil,
        breastfeedingRightMinutes: Int? = nil,
        sleepStart: Date? = nil,
        sleepEnd: Date? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        temperature: Double? = nil,
        content: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.mlAmount = mlAmount
        self.breastfeedingLeftMinutes = breastfeedingLeftMinutes
        self.breastfeedingRightMinutes = breastfeedingRightMinutes
        self.sleepStart = sleepStart
        self.sleepEnd = sleepEnd
        self.height = height
        self.weight = weight
        self.temperature = temperature
        self.content = content
    }
}

extension Record {
    public static let mockRecords: [Record] = [
        Record(createdAt: Date(), title: .formula, mlAmount: 120),
        Record(createdAt: Date().addingTimeInterval(-3600), title: .diaper),
        Record(
            createdAt: Date().addingTimeInterval(-7200),
            title: .sleep,
            sleepStart: Date().addingTimeInterval(-10800),
            sleepEnd: Date().addingTimeInterval(-7200)
        )
    ]
}
