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
    @Published var hasBabyInfo: Bool? = nil
    let auth = AuthService.shared
    let db = Firestore.firestore()
    static let shared = DatabaseService()
    
    private init() {
        let settings = Firestore.firestore().settings
        settings.cacheSettings = MemoryCacheSettings()
                Firestore.firestore().settings = settings
    }
    
    func checkBabyInfo() async -> Bool {
            guard let uid = auth.user?.uid else { return false }
            do {
                let document = try await db.collection("users").document(uid).getDocument(source: .server)
                return (document.get("babies") as? [DocumentReference])?.isEmpty == false
            } catch {
                return false
            }
        }
    
    
    func saveBabyInfo(baby: Baby) async throws {
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        // Codable을 사용해 Baby 객체를 직렬화
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(baby)
        try await babyRef.setData(data)
        
        // 사용자 문서에 아기 참조 추가
        guard let uid = auth.user?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        let userDocRef = db.collection("users").document(uid)
        try await userDocRef.setData([
            "babies": FieldValue.arrayUnion([babyRef])
        ], merge: true)
        
        // 아기 문서에 보호자 참조 추가
        try await babyRef.setData([
            "caregivers": FieldValue.arrayUnion([userDocRef])
        ], merge: true)
        
        // 아기 정보가 추가되었으므로 hasBabyInfo 갱신
        self.hasBabyInfo = true
    }
}
