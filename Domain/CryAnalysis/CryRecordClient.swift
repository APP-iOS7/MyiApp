import Foundation

public struct CryRecordClient: Sendable {
    public var loadRecords: @Sendable (UUID, Range<Date>) async throws(CryRecordError) -> [CryAnalysisRecord]
    public var addRecord: @Sendable (UUID, CryAnalysisRecord) async throws(CryRecordError) -> Void
    public var deleteRecord: @Sendable (UUID, UUID) async throws(CryRecordError) -> Void

    public init(
        loadRecords: @escaping @Sendable (UUID, Range<Date>) async throws(CryRecordError) -> [CryAnalysisRecord],
        addRecord: @escaping @Sendable (UUID, CryAnalysisRecord) async throws(CryRecordError) -> Void,
        deleteRecord: @escaping @Sendable (UUID, UUID) async throws(CryRecordError) -> Void
    ) {
        self.loadRecords = loadRecords
        self.addRecord = addRecord
        self.deleteRecord = deleteRecord
    }
}
