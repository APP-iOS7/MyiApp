//
//  DatabaseService.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-10.
//

import Foundation
import FirebaseFirestore

@MainActor
class DatabaseService: ObservableObject {
    @Published var hasBabyInfo: Bool = false
    let auth = AuthService.shared
    let db = Firestore.firestore()
    static let shared = DatabaseService()
    
    private init() {
        observeBabyInfoWithCombine()
    }
    
    func observeBabyInfoWithCombine() {
        guard let uid = auth.user?.uid else {
            self.hasBabyInfo = false
            return
        }
        let docRef = db.collection("users").document(uid)
        docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let document = snapshot, document.exists {
                if let babies = document.get("babies") as? [DocumentReference] {
                    DispatchQueue.main.async {
                        self.hasBabyInfo = !babies.isEmpty
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hasBabyInfo = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hasBabyInfo = false
                }
            }
        }
    }
    
    func saveBabyInfo(baby: Baby) async throws {
        // 아기의 정보를 babies collection에 uuid필드에 저장.
        try db.collection("babies")
            .document(baby.id.uuidString)
            .setData(from: baby)
        // 아기의 ref 정보를 users의 babies배열에 저장.
        guard let uid = auth.user?.uid else { return }
        let userDocRef = db.collection("users").document(uid)
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        try await userDocRef.setData([
            "babies": FieldValue.arrayUnion([babyRef])
        ], merge: true)
        // 보호자의 ref를 아기의 caregivers 배열에 저장.
        try await babyRef.setData([
            "caregivers": FieldValue.arrayUnion([userDocRef])
        ], merge: true)
    }
}
