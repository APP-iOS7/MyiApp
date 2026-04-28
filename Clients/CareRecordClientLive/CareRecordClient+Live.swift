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
        addRecord: { @Sendable babyID, record async throws(CareRecordError) -> Void in
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
        updateRecord: { @Sendable babyID, record async throws(CareRecordError) -> Void in
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
        deleteRecord: { @Sendable babyID, recordID async throws(CareRecordError) -> Void in
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

public extension DependencyValues {
    var careRecordClient: CareRecordClient {
        get { self[CareRecordClient.self] }
        set { self[CareRecordClient.self] = newValue }
    }
}
