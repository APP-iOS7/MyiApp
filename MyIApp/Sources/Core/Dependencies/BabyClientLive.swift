import ComposableArchitecture
import FirebaseFirestore
import Foundation

extension BabyClient: DependencyKey {
    public static let liveValue: BabyClient = {
        @Dependency(\.authClient) var authClient

        return .init(
            fetchBabies: {
                guard let uid = await authClient.currentSession()?.userID else {
                    throw NSError(
                        domain: "BabyClient",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "인증되지 않은 사용자입니다."]
                    )
                }

                let db = Firestore.firestore()
                let userRef = db.collection("users").document(uid)
                let userSnapshot = try await userRef.getDocument()

                guard let data = userSnapshot.data(),
                      let babyRefs = data["babies"] as? [DocumentReference]
                else {
                    return []
                }

                var babies: [Baby] = []
                for ref in babyRefs {
                    let babySnapshot = try await ref.getDocument()
                    guard let babyData = babySnapshot.data() else {
                        continue
                    }

                    let baby = Baby(
                        id: ref.documentID,
                        name: babyData["name"] as? String ?? "",
                        gender: Gender(rawValue: babyData["gender"] as? String ?? "") ?? .male,
                        birthDate: (babyData["birthDate"] as? Timestamp)?.dateValue() ?? Date(),
                        height: babyData["height"] as? Double ?? 0.0,
                        weight: babyData["weight"] as? Double ?? 0.0,
                        bloodType: BloodType(rawValue: babyData["bloodType"] as? String ?? "") ?? .a,
                        photoURL: babyData["photoURL"] as? String,
                        mainCaregiver: babyData["mainCaregiver"] as? String ?? "",
                        caregivers: (babyData["caregivers"] as? [DocumentReference])?.map(\.documentID) ?? []
                    )
                    babies.append(baby)
                }

                return babies
            },
            registerNewBaby: { request in
                guard let uid = await authClient.currentSession()?.userID else {
                    throw NSError(
                        domain: "BabyClient",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "인증되지 않은 사용자입니다."]
                    )
                }

                let db = Firestore.firestore()
                let babyID = UUID().uuidString
                let babyRef = db.collection("babies").document(babyID)
                let userRef = db.collection("users").document(uid)

                // TODO: 아래의 복합적인 문서 생성 및 참조 업데이트 로직은 원자성 보장 및 보안을 위해 백엔드(Cloud Functions)로 이전 예정입니다.
                let babyData: [String: Any] = [
                    "id": babyID,
                    "name": request.name,
                    "gender": request.gender.rawValue,
                    "birthDate": request.birthDate,
                    "height": request.height,
                    "weight": request.weight,
                    "bloodType": request.bloodType.rawValue,
                    "caregivers": [userRef],
                    "mainCaregiver": uid,
                    "createdAt": FieldValue.serverTimestamp()
                ]

                try await babyRef.setData(babyData)
                try await userRef.updateData([
                    "babies": FieldValue.arrayUnion([babyRef])
                ])

                return Baby(
                    id: babyID,
                    name: request.name,
                    gender: request.gender,
                    birthDate: request.birthDate,
                    height: request.height,
                    weight: request.weight,
                    bloodType: request.bloodType,
                    mainCaregiver: uid,
                    caregivers: [uid]
                )
            },
            registerExistingBaby: { invitationCode in
                guard let uid = await authClient.currentSession()?.userID else {
                    throw NSError(
                        domain: "BabyClient",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "인증되지 않은 사용자입니다."]
                    )
                }

                let db = Firestore.firestore()
                let babyRef = db.collection("babies").document(invitationCode)
                let userRef = db.collection("users").document(uid)

                // TODO: 초대 코드 검증 및 상호 참조 연결 로직은 데이터 무결성을 위해 백엔드(Cloud Functions)로 이전 예정입니다.
                let snapshot = try await babyRef.getDocument()
                guard snapshot.exists, let data = snapshot.data() else {
                    throw NSError(
                        domain: "BabyClient",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "해당 코드를 가진 아기를 찾을 수 없습니다."]
                    )
                }

                // 사용자 문서에 아기 참조 추가 및 아기 문서에 보호자 참조 추가 (Link)
                try await userRef.updateData([
                    "babies": FieldValue.arrayUnion([babyRef])
                ])
                try await babyRef.updateData([
                    "caregivers": FieldValue.arrayUnion([userRef])
                ])

                // 아기 정보 파싱 및 반환
                return Baby(
                    id: invitationCode,
                    name: data["name"] as? String ?? "",
                    gender: Gender(rawValue: data["gender"] as? String ?? "") ?? .male,
                    birthDate: (data["birthDate"] as? Timestamp)?.dateValue() ?? Date(),
                    height: data["height"] as? Double ?? 0.0,
                    weight: data["weight"] as? Double ?? 0.0,
                    bloodType: BloodType(rawValue: data["bloodType"] as? String ?? "") ?? .a,
                    photoURL: data["photoURL"] as? String,
                    mainCaregiver: data["mainCaregiver"] as? String ?? "",
                    caregivers: (data["caregivers"] as? [DocumentReference])?.map(\.documentID) ?? []
                )
            }
        )
    }()
}

extension DependencyValues {
    public var babyClient: BabyClient {
        get { self[BabyClient.self] }
        set { self[BabyClient.self] = newValue }
    }
}
