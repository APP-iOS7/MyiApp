import Foundation

public struct RecordClient: Sendable {
    public var fetchRecords: @Sendable (String) async throws(RecordError) -> [Record]
    public var saveRecord: @Sendable (Record) async throws(RecordError) -> Void
    public var deleteRecord: @Sendable (String) async throws(RecordError) -> Void

    public init(
        fetchRecords: @escaping @Sendable (String) async throws(RecordError) -> [Record],
        saveRecord: @escaping @Sendable (Record) async throws(RecordError) -> Void,
        deleteRecord: @escaping @Sendable (String) async throws(RecordError) -> Void
    ) {
        self.fetchRecords = fetchRecords
        self.saveRecord = saveRecord
        self.deleteRecord = deleteRecord
    }
}
