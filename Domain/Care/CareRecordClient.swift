import Foundation

public struct CareRecordClient: Sendable {
    public var loadRecords: @Sendable (UUID, Range<Date>) async throws(CareRecordError) -> [CareRecord]
    public var lastEvent: @Sendable (UUID, CareEvent.Category) async throws(CareRecordError) -> CareEvent?
    public var addRecord: @Sendable (UUID, CareRecord) async throws(CareRecordError) -> Void
    public var updateRecord: @Sendable (UUID, CareRecord) async throws(CareRecordError) -> Void
    public var deleteRecord: @Sendable (UUID, UUID) async throws(CareRecordError) -> Void

    public init(
        loadRecords: @escaping @Sendable (UUID, Range<Date>) async throws(CareRecordError) -> [CareRecord],
        lastEvent: @escaping @Sendable (UUID, CareEvent.Category) async throws(CareRecordError) -> CareEvent?,
        addRecord: @escaping @Sendable (UUID, CareRecord) async throws(CareRecordError) -> Void,
        updateRecord: @escaping @Sendable (UUID, CareRecord) async throws(CareRecordError) -> Void,
        deleteRecord: @escaping @Sendable (UUID, UUID) async throws(CareRecordError) -> Void
    ) {
        self.loadRecords = loadRecords
        self.lastEvent = lastEvent
        self.addRecord = addRecord
        self.updateRecord = updateRecord
        self.deleteRecord = deleteRecord
    }
}
