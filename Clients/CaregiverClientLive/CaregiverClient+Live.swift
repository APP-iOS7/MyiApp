import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

extension CaregiverClient: @retroactive TestDependencyKey {}
extension CaregiverClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        currentCaregiver: { @Sendable () async throws(CaregiverError) -> Caregiver? in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw CaregiverError.unauthorized
            }
            do {
                let snapshot = try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .getDocument()
                return try caregiver(from: snapshot)
            } catch {
                throw CaregiverError.unexpected
            }
        },
        streamCaregiver: { @Sendable () -> AsyncStream<Caregiver?> in
            AsyncStream { continuation in
                guard let uid = Auth.auth().currentUser?.uid else {
                    continuation.finish()
                    return
                }
                let listener = Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .addSnapshotListener { snapshot, _ in
                        guard let snapshot else { return }
                        continuation.yield(try? caregiver(from: snapshot))
                    }
                continuation.onTermination = { _ in
                    listener.remove()
                }
            }
        },
        provisionCaregiver: { @Sendable initial async throws(CaregiverError) -> Void in
            guard Auth.auth().currentUser?.uid == initial.id else {
                throw CaregiverError.unauthorized
            }
            do {
                let ref = Firestore.firestore().collection("users").document(initial.id)
                let snapshot = try await ref.getDocument()
                if snapshot.exists, snapshot.data()?["createdAt"] != nil {
                    return
                }
                let encoder = Firestore.Encoder()
                let data = try encoder.encode(initial)
                try await ref.setData(data, merge: true)
            } catch {
                throw CaregiverError.unexpected
            }
        },
        updateDisplayName: { @Sendable name async throws(CaregiverError) -> Void in
            guard let uid = Auth.auth().currentUser?.uid else {
                throw CaregiverError.unauthorized
            }
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData(["displayName": name], merge: true)
            } catch {
                throw CaregiverError.unexpected
            }
        }
    )
}

public extension DependencyValues {
    var caregiverClient: CaregiverClient {
        get { self[CaregiverClient.self] }
        set { self[CaregiverClient.self] = newValue }
    }
}

private func caregiver(from snapshot: DocumentSnapshot) throws -> Caregiver? {
    guard snapshot.exists, var data = snapshot.data() else { return nil }
    data["id"] = snapshot.documentID
    let decoder = Firestore.Decoder()
    return try decoder.decode(Caregiver.self, from: data)
}
