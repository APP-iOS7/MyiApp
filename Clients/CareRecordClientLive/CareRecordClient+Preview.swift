#if DEBUG
import Domain
import Foundation

extension CareRecordClient {
    public static let previewValue = Self(
        loadRecords: { _, range async throws(CareRecordError) -> [CareRecord] in
            CareRecord.mocks.filter { range.contains($0.createdAt) }
        },
        lastEvent: { _, category async throws(CareRecordError) -> CareEvent? in
            CareRecord.mocks
                .filter { $0.event.category == category }
                .max(by: { $0.createdAt < $1.createdAt })?
                .event
        },
        addRecord: { _, _ in },
        updateRecord: { _, _ in },
        deleteRecord: { _, _ in }
    )
}
#endif
