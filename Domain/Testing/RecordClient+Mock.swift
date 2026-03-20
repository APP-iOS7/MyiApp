import Domain
import Foundation

extension Record {
    public static var mock: Self {
        Record(
            id: "mock_record_id",
            babyID: "mock_baby_id",
            type: .feeding,
            timestamp: Date(),
            note: "Mock record note"
        )
    }
}

extension RecordClient {
    public static var mock: Self {
        RecordClient(
            fetchRecords: { _ throws(RecordError) in [.mock] },
            saveRecord: { _ throws(RecordError) in },
            deleteRecord: { _ throws(RecordError) in }
        )
    }

    public static func failing(error: RecordError) -> Self {
        RecordClient(
            fetchRecords: { _ throws(RecordError) in throw error },
            saveRecord: { _ throws(RecordError) in throw error },
            deleteRecord: { _ throws(RecordError) in throw error }
        )
    }
}
