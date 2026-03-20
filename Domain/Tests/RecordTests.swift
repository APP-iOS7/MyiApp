import Foundation
import Testing
@testable import Domain

struct RecordTests {
    @Test("기록 데이터 초기화 확인")
    func recordDataInitialization() {
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
        #expect(record.id == id)
        #expect(record.babyID == babyID)
        #expect(record.type == .cry)
        #expect(record.timestamp == timestamp)
        #expect(record.note == note)
    }

    @Test("Note 모델 데이터 초기화 확인")
    func noteModelDataInitialization() {
        // Given
        let recordID = "record-1"
        let content = "수유 기록 상세 내용"

        // When
        let note = Note(recordID: recordID, content: content)

        // Then
        #expect(note.recordID == recordID)
        #expect(note.content == content)
    }
}
