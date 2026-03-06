//
//  BabyCaregiverFirestoreMapping.swift
//  MyiApp
//
//  Firestore DocumentReference <-> 도메인 ID 배열 매핑. Baby/Caregiver는 Firebase 의존성 없음.
//

import FirebaseFirestore
import Foundation

// MARK: - Caregiver

extension Caregiver {
    /// Firestore 사용자 문서에서 Caregiver 생성. "babies" 필드는 [DocumentReference] → babyIds로 변환.
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        let babyRefs = data["babies"] as? [DocumentReference] ?? []
        self.id = document.documentID
        self.name = data["name"] as? String
        self.email = data["email"] as? String
        self.provider = data["provider"] as? String
        self.babyIds = babyRefs.map(\.documentID)
        self.lastSelectedBabyId = data["lastSelectedBabyId"] as? String
    }

    /// Firestore에 쓸 수 있는 딕셔너리. babyIds를 [DocumentReference]로 변환.
    func toFirestoreData(db: Firestore) -> [String: Any] {
        [
            "id": id,
            "name": name as Any,
            "email": email as Any,
            "provider": provider as Any,
            "babies": babyIds.map { db.collection("babies").document($0) },
            "lastSelectedBabyId": lastSelectedBabyId as Any,
        ]
    }
}

// MARK: - Baby

extension Baby {
    /// Firestore 아기 문서에서 Baby 생성. "caregivers" 필드는 [DocumentReference] → caregiverIds로 변환.
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["name"] as? String,
            let ts = data["birth_date"] as? Timestamp,
            let genderRaw = data["gender"] as? Int,
            let gender = Gender(rawValue: genderRaw),
            let height = data["height"] as? Double,
            let weight = data["weight"] as? Double,
            let bloodTypeRaw = data["blood_type"] as? String,
            let bloodType = BloodType(rawValue: bloodTypeRaw),
            let mainCaregiver = data["mainCaregiver"] as? String
        else { return nil }
        let birthDate = Date(
            timeIntervalSince1970: TimeInterval(ts.seconds) + TimeInterval(ts.nanoseconds)
                / 1_000_000_000)
        let caregiverRefs = data["caregivers"] as? [DocumentReference] ?? []
        let idString = data["id"] as? String ?? document.documentID
        self.id = UUID(uuidString: idString) ?? UUID()
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.photoURL = data["photoURL"] as? String
        self.mainCaregiver = mainCaregiver
        self.caregiverIds = caregiverRefs.map(\.documentID)
    }

    /// Firestore에 쓸 수 있는 딕셔너리. caregiverIds를 [DocumentReference]로 변환.
    func toFirestoreData(db: Firestore) -> [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "birth_date": Timestamp(date: birthDate),
            "gender": gender.rawValue,
            "height": height,
            "weight": weight,
            "blood_type": bloodType.rawValue,
            "photoURL": photoURL as Any,
            "mainCaregiver": mainCaregiver,
            "caregivers": caregiverIds.map { db.collection("users").document($0) },
        ]
    }
}
