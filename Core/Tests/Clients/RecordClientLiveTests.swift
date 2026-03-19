import Domain
import FirebaseCore
import FirebaseFirestore
import XCTest
@testable import Core

final class RecordClientLiveTests: XCTestCase {
    var db: Firestore!
    var client: RecordClient!

    override class func setUp() {
        super.setUp()
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(
                googleAppID: "1:1234567890:ios:321abc456def7890",
                gcmSenderID: "1234567890"
            )
            options.projectID = "demo-myiapp"
            options.apiKey = "AIzaSyDummyKey123456789"
            FirebaseApp.configure(options: options)
        }
    }

    override func setUp() {
        super.setUp()
        self.db = Firestore.firestore()
        let settings = self.db.settings
        settings.host = "127.0.0.1:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        self.db.settings = settings

        self.client = RecordClient.liveValue
    }

    func test_Given_기록정보_When_saveRecord호출시_Then_성공적으로저장됨() async throws {
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
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.id, record.id)
        XCTAssertEqual(records.first?.type, .feeding)
        XCTAssertEqual(records.first?.metadata?["amount"], "120ml")
    }

    func test_Given_여러기록_When_fetchRecords호출시_Then_최신순으로정렬됨() async throws {
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
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0].id, newRecord.id)
        XCTAssertEqual(records[1].id, oldRecord.id)
    }

    func test_Given_기존기록_When_deleteRecord호출시_Then_삭제됨() async throws {
        // Given
        let babyID = UUID().uuidString
        let record = Record(babyID: babyID, type: .cry)
        try await client.saveRecord(record)

        // When
        try await self.client.deleteRecord(record.id)

        // Then
        let records = try await client.fetchRecords(babyID)
        XCTAssertTrue(records.isEmpty)
    }
}
