import Foundation

public struct Record: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let babyID: String
    public let type: RecordType
    public let timestamp: Date
    public let note: String?
    public let metadata: [String: String]? // 유연한 확장을 위한 메타데이터

    public init(
        id: String = UUID().uuidString,
        babyID: String,
        type: RecordType,
        timestamp: Date = Date(),
        note: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.babyID = babyID
        self.type = type
        self.timestamp = timestamp
        self.note = note
        self.metadata = metadata
    }
}
