import XCTest

@testable import Domain

final class RecordTests: XCTestCase {
    func test_Given_기록데이터가있을때_When_초기화하면_Then_모든데이터가정상적으로설정됨() {
        // Given
        let id = "record-1"
        let babyID = "baby-1"
        let timestamp = Date()
        let note = "테스트 메모"

        // When
        let record = Record(
            id: id,
            babyID: babyID,
            type: .cry,
            timestamp: timestamp,
            note: note
        )

        // Then
        XCTAssertEqual(record.id, id)
        XCTAssertEqual(record.babyID, babyID)
        XCTAssertEqual(record.type, .cry)
        XCTAssertEqual(record.timestamp, timestamp)
        XCTAssertEqual(record.note, note)
    }

    func test_Given_상세기록데이터가있을때_When_초기화하면_Then_데이터가정상적으로설정됨() {
        // Given
        let recordID = "record-1"
        let content = "수유 기록 상세 내용"

        // When
        let note = Note(recordID: recordID, content: content)

        // Then
        XCTAssertEqual(note.recordID, recordID)
        XCTAssertEqual(note.content, content)
    }
}
