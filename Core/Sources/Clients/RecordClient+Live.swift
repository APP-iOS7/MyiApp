import Domain
import FirebaseFirestore
import Foundation

extension RecordClient {
    public static var liveValue: Self {
        let db = Firestore.firestore()

        return Self(
            fetchRecords: { babyID in
                let snapshot = try await db.collection("records")
                    .whereField("babyID", isEqualTo: babyID)
                    .order(by: "timestamp", descending: true)
                    .getDocuments()

                return snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    guard let typeString = data["type"] as? String,
                          let type = RecordType(rawValue: typeString),
                          let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                    else {
                        return nil
                    }

                    return Record(
                        id: doc.documentID,
                        babyID: babyID,
                        type: type,
                        timestamp: timestamp,
                        note: data["note"] as? String,
                        metadata: data["metadata"] as? [String: String]
                    )
                }
            },
            saveRecord: { record in
                let data: [String: Any] = [
                    "babyID": record.babyID,
                    "type": record.type.rawValue,
                    "timestamp": Timestamp(date: record.timestamp),
                    "note": record.note as Any,
                    "metadata": record.metadata as Any
                ]
                try await db.collection("records").document(record.id).setData(data)
            },
            deleteRecord: { id in
                try await db.collection("records").document(id).delete()
            }
        )
    }
}
