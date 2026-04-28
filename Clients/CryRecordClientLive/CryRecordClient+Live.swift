import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

extension CryRecordClient: @retroactive TestDependencyKey {}
extension CryRecordClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        loadRecords: { @Sendable babyID, range async throws(CryRecordError) -> [CryAnalysisRecord] in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                let snapshot = try await recordsCollection(babyID: babyID)
                    .whereField("createdAt", isGreaterThanOrEqualTo: range.lowerBound)
                    .whereField("createdAt", isLessThan: range.upperBound)
                    .order(by: "createdAt", descending: true)
                    .getDocuments()
                let decoder = Firestore.Decoder()
                return try snapshot.documents.map { doc in
                    try decoder.decode(CryAnalysisRecord.self, from: doc.data())
                }
            } catch {
                throw .unexpected
            }
        },
        addRecord: { @Sendable babyID, record async throws(CryRecordError) -> Void in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                let data = try Firestore.Encoder().encode(record)
                try await recordsCollection(babyID: babyID)
                    .document(record.id.uuidString)
                    .setData(data)
            } catch {
                throw .unexpected
            }
        },
        deleteRecord: { @Sendable babyID, recordID async throws(CryRecordError) -> Void in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                try await recordsCollection(babyID: babyID)
                    .document(recordID.uuidString)
                    .delete()
            } catch {
                throw .unexpected
            }
        }
    )
}

public extension DependencyValues {
    var cryRecordClient: CryRecordClient {
        get { self[CryRecordClient.self] }
        set { self[CryRecordClient.self] = newValue }
    }
}

private func recordsCollection(babyID: UUID) -> CollectionReference {
    Firestore.firestore()
        .collection("babies")
        .document(babyID.uuidString)
        .collection("cryRecords")
}
