import Foundation

public struct GrowthRecord: Identifiable, Hashable, Sendable, Codable {
    public enum Measurement: Hashable, Sendable, Codable {
        case height(cm: Double)
        case weight(kg: Double)
        case both(heightCm: Double, weightKg: Double)
    }

    public let id: UUID
    public var measurement: Measurement
    public var recordedAt: Date

    public init(
        id: UUID = UUID(),
        measurement: Measurement,
        recordedAt: Date = .init()
    ) {
        self.id = id
        self.measurement = measurement
        self.recordedAt = recordedAt
    }
}
