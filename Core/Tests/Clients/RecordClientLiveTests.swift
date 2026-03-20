import Domain
import FirebaseCore
import FirebaseFirestore
import Foundation
import Testing
@testable import Core

@Suite(.serialized)
struct RecordClientLiveTests {
    private let db: Firestore
    private let client: RecordClient

    init() {
        FirebaseTestEnvironment.shared.setup()
        self.db = Firestore.firestore()
        self.client = RecordClient.liveValue
    }

    @Test("기록 저장 및 조회 성공")
    func saveAndFetchRecordSuccess() async throws {
        guard await FirebaseEmulatorCheck.isFirestoreEmulatorRunning() else {
            return
        }

        // Given
        let babyID = UUID().uuidString
        let record = Record(
            babyID: babyID,
            type: .feeding,
            timestamp: Date(),
            note: "테스트 수유 기록",
            metadata: ["amount": "120ml"]
        )

        // When
        try await client.saveRecord(record)

        // Then
        let records = try await client.fetchRecords(babyID)
        #expect(records.count == 1)
        #expect(records.first?.id == record.id)
        #expect(records.first?.type == .feeding)
        #expect(records.first?.metadata?["amount"] == "120ml")
    }

    @Test("여러 기록 조회 시 최신순 정렬 확인")
    func fetchRecordsAreSortedByLatest() async throws {
        guard await FirebaseEmulatorCheck.isFirestoreEmulatorRunning() else {
            return
        }

        // Given
        let babyID = UUID().uuidString
        let now = Date()
        let oldRecord = Record(
            babyID: babyID,
            type: .sleep,
            timestamp: now.addingTimeInterval(-3600)
        )
        let newRecord = Record(babyID: babyID, type: .diaper, timestamp: now)

        try await client.saveRecord(oldRecord)
        try await self.client.saveRecord(newRecord)

        // When
        let records = try await client.fetchRecords(babyID)

        // Then
        #expect(records.count == 2)
        #expect(records[0].id == newRecord.id)
        #expect(records[1].id == oldRecord.id)
    }

    @Test("기록 삭제 성공")
    func deleteRecordSuccess() async throws {
        guard await FirebaseEmulatorCheck.isFirestoreEmulatorRunning() else {
            return
        }

        // Given
        let babyID = UUID().uuidString
        let record = Record(babyID: babyID, type: .cry)
        try await client.saveRecord(record)

        // When
        try await self.client.deleteRecord(record.id)

        // Then
        let records = try await client.fetchRecords(babyID)
        #expect(records.isEmpty == true)
    }
}
