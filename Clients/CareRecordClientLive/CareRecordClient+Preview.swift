#if DEBUG
import Domain
import Foundation

extension CareRecordClient {
    public static let previewValue = Self(
        loadRecords: { _, range async throws(CareRecordError) -> [CareRecord] in
            CareRecord.mocks.filter { range.contains($0.createdAt) }
        },
        addRecord: { _, _ in },
        updateRecord: { _, _ in },
        deleteRecord: { _, _ in }
    )
}
#endif
