import Foundation

public struct RecordClient: Sendable {
    public var fetchRecords: @Sendable (String) async throws -> [Record]
    public var saveRecord: @Sendable (Record) async throws -> Void
    public var deleteRecord: @Sendable (String) async throws -> Void

    public init(
        fetchRecords: @escaping @Sendable (String) async throws -> [Record],
        saveRecord: @escaping @Sendable (Record) async throws -> Void,
        deleteRecord: @escaping @Sendable (String) async throws -> Void
    ) {
        self.fetchRecords = fetchRecords
        self.saveRecord = saveRecord
        self.deleteRecord = deleteRecord
    }
}
