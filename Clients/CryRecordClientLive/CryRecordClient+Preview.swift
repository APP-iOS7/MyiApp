#if DEBUG
import ConcurrencyExtras
import Domain
import Foundation

extension CryRecordClient {
    public static var previewValue: Self {
        let store = LockIsolated<[CryAnalysisRecord]>([])
        return Self(
            loadRecords: { @Sendable _, range async throws(CryRecordError) -> [CryAnalysisRecord] in
                store.value.filter { range.contains($0.createdAt) }
            },
            addRecord: { @Sendable _, record async throws(CryRecordError) -> Void in
                store.withValue { $0.insert(record, at: 0) }
            },
            deleteRecord: { @Sendable _, recordID async throws(CryRecordError) -> Void in
                store.withValue { $0.removeAll { $0.id == recordID } }
            }
        )
    }
}
#endif
