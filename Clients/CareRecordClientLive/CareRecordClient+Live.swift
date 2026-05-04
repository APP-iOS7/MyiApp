import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore

extension CareRecordClient: @retroactive TestDependencyKey {}
extension CareRecordClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        loadRecords: { @Sendable babyID, range async throws(CareRecordError) -> [CareRecord] in
            guard Auth.auth().currentUser?.uid != nil else {
                throw CareRecordError.unauthorized
            }

            do {
                let snapshot = try await recordsCollection(babyID: babyID)
                    .whereField("createdAt", isGreaterThanOrEqualTo: range.lowerBound)
                    .whereField("createdAt", isLessThan: range.upperBound)
                    .order(by: "createdAt")
                    .getDocuments()
                let decoder = Firestore.Decoder()
                return try snapshot.documents.map { doc in
                    try decoder.decode(CareRecord.self, from: doc.data())
                }
            } catch {
                throw CareRecordError.unexpected
            }
        },
        lastEvent: { @Sendable babyID, category async throws(CareRecordError) -> CareEvent? in
            guard Auth.auth().currentUser?.uid != nil else {
                throw CareRecordError.unauthorized
            }

            do {
                // TODO: 최적화 — 현재 top 50 doc을 가져와 메모리에서 카테고리 매칭.
                // 데이터 누적 시 비효율. 와이어 포맷에 category 필드를 denormalize 저장하고
                // .whereField("category", isEqualTo: ...).limit(to: 1)로 단건 쿼리하도록 마이그.
                let snapshot = try await recordsCollection(babyID: babyID)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 50)
                    .getDocuments()
                let decoder = Firestore.Decoder()
                let records = try snapshot.documents.map { doc in
                    try decoder.decode(CareRecord.self, from: doc.data())
                }
                return records.first { $0.event.category == category }?.event
            } catch {
                throw CareRecordError.unexpected
            }
        },
        addRecord: { @Sendable babyID, record async throws(CareRecordError) in
            guard Auth.auth().currentUser?.uid != nil else {
                throw CareRecordError.unauthorized
            }

            do {
                let data = try Firestore.Encoder().encode(record)
                try await recordsCollection(babyID: babyID)
                    .document(record.id.uuidString)
                    .setData(data)
            } catch {
                throw CareRecordError.unexpected
            }
        },
        updateRecord: { @Sendable babyID, record async throws(CareRecordError) in
            guard Auth.auth().currentUser?.uid != nil else {
                throw CareRecordError.unauthorized
            }

            do {
                let data = try Firestore.Encoder().encode(record)
                try await recordsCollection(babyID: babyID)
                    .document(record.id.uuidString)
                    .setData(data, merge: false)
            } catch {
                throw CareRecordError.unexpected
            }
        },
        deleteRecord: { @Sendable babyID, recordID async throws(CareRecordError) in
            guard Auth.auth().currentUser?.uid != nil else {
                throw CareRecordError.unauthorized
            }

            do {
                try await recordsCollection(babyID: babyID)
                    .document(recordID.uuidString)
                    .delete()
            } catch {
                throw CareRecordError.unexpected
            }
        }
    )
}

private func recordsCollection(babyID: UUID) -> CollectionReference {
    Firestore.firestore()
        .collection("babies")
        .document(babyID.uuidString)
        .collection("records")
}

extension DependencyValues {
    public var careRecordClient: CareRecordClient {
        get { self[CareRecordClient.self] }
        set { self[CareRecordClient.self] = newValue }
    }
}
