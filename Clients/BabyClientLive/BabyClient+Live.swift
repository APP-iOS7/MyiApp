import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore

extension BabyClient: @retroactive TestDependencyKey {}
extension BabyClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        registerNewBaby: { @Sendable baby, initial async throws(BabyError) -> Void in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw BabyError.unauthorized
            }

            let db = Firestore.firestore()
            let babyRef = db.collection("babies").document(baby.id.uuidString)
            let userRef = db.collection("users").document(uid)
            let recordRef = babyRef.collection("growthRecords").document(initial.id.uuidString)

            do {
                let encoder = Firestore.Encoder()
                let babyData = try encoder.encode(baby)
                let recordData = try encoder.encode(initial)

                try await babyRef.setData(babyData)
                try await recordRef.setData(recordData)
                try await userRef.setData([
                    "babyIDs": FieldValue.arrayUnion([baby.id.uuidString])
                ], merge: true)
            } catch {
                throw BabyError.unexpected
            }
        },
        registerExistingBaby: { @Sendable inviteCode async throws(BabyError) -> Void in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw BabyError.unauthorized
            }

            let db = Firestore.firestore()
            let babyRef = db.collection("babies").document(inviteCode)
            let userRef = db.collection("users").document(uid)

            let snapshot: DocumentSnapshot
            do {
                snapshot = try await babyRef.getDocument()
            } catch {
                throw BabyError.unexpected
            }

            guard snapshot.exists else {
                throw BabyError.invalidInviteCode
            }

            do {
                try await babyRef.setData([
                    "caregiverIDs": FieldValue.arrayUnion([uid])
                ], merge: true)
                try await userRef.setData([
                    "babyIDs": FieldValue.arrayUnion([inviteCode])
                ], merge: true)
            } catch {
                throw BabyError.unexpected
            }
        }
    )
}

public extension DependencyValues {
    var babyClient: BabyClient {
        get { self[BabyClient.self] }
        set { self[BabyClient.self] = newValue }
    }
}
