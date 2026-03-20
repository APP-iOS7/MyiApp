import Domain
import FirebaseFirestore
import Foundation

extension CaregiverClient {
    public static var live: Self {
        let db = Firestore.firestore()

        return Self(
            fetchCaregiver: { uid async throws(CaregiverError) in
                do {
                    let snapshot = try await db.collection("users").document(uid).getDocument()
                    guard let data = snapshot.data() else {
                        throw CaregiverError.notFound
                    }

                    return Caregiver(
                        id: uid,
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        role: data["role"] as? String,
                        lastSelectedBabyID: data["lastSelectedBabyId"] as? String
                    )
                } catch let error as CaregiverError {
                    throw error
                } catch {
                    throw CaregiverError.internalError(error)
                }
            },
            registerCaregiver: { caregiver async throws(CaregiverError) in
                let data: [String: Any] = [
                    "id": caregiver.id,
                    "name": caregiver.name,
                    "email": caregiver.email,
                    "role": caregiver.role as Any,
                    "lastSelectedBabyId": caregiver.lastSelectedBabyID as Any,
                    "babies": [] // 초기 가입 시 빈 배열
                ]
                do {
                    try await db.collection("users").document(caregiver.id).setData(data)
                } catch {
                    throw CaregiverError.internalError(error)
                }
            },
            connectCaregiver: { caregiverID, babyID async throws(CaregiverError) in
                let userRef = db.collection("users").document(caregiverID)
                let babyRef = db.collection("babies").document(babyID)

                do {
                    _ = try await db.runTransaction { transaction, _ in
                        // 1. 사용자 문서에 아기 참조 추가
                        transaction.updateData([
                            "babies": FieldValue.arrayUnion([babyRef])
                        ], forDocument: userRef)

                        // 2. 아기 문서에 보호자 참조 추가
                        transaction.updateData([
                            "caregivers": FieldValue.arrayUnion([userRef])
                        ], forDocument: babyRef)

                        return nil
                    }
                } catch {
                    throw CaregiverError.internalError(error)
                }
            }
        )
    }
}
