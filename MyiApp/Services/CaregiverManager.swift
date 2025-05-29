//
//  CaregiverManager.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-14.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

class CaregiverManager: ObservableObject {
    @Published var caregiver: Caregiver?
    @Published var babies: [Baby] = []
    @Published var selectedBaby: Baby? {
        didSet {
            cancellables.removeAll()
            subscribeToRecords()
            subscribeToNotes()
            subscribeToVoiceRecords()
        }
    }
    private let db = Firestore.firestore()
    private var cancellables: Set<AnyCancellable> = []
    static let shared = CaregiverManager()
    @Published var userName: String? = nil
    @Published var email: String? = nil
    @Published var provider: String? = nil
    @Published var records: [Record] = []
    @Published var voiceRecords: [VoiceRecord] = []
    @Published var notes: [Note] = []
    private init() { }
    
    
    func loadCaregiverInfo() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if let caregiver = await loadCaregiver(uid: uid) {
            let babies = await loadBabies(from: caregiver.babies)
            await MainActor.run {
                self.caregiver = caregiver
                self.babies = babies
                self.selectedBaby = babies.first
                self.userName = caregiver.name
                self.email = caregiver.email
                self.provider = caregiver.provider
            }
        } else {
            print("Error from CaregiverManager.loadCaregiverInfo")
            await saveCaregiverInfo()
        }
    }
    
    @MainActor
    func saveCaregiverInfo() async {
        guard let user = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(user.uid)
        if let existingCaregiver = try? await userRef.getDocument().data(as: Caregiver.self) {
            // 기존 데이터 존재하면 유지
            self.caregiver = existingCaregiver
            self.userName = existingCaregiver.name
            self.email = existingCaregiver.email
            self.provider = existingCaregiver.provider
        } else {
            // 신규 사용자 데이터 저장
            let caregiver = Caregiver(
                id: user.uid,
                name: user.displayName,
                email: user.email,
                provider: user.providerData.first?.providerID,
                babies: []
            )
            let _ = userRef.setData(from: caregiver)
            self.caregiver = caregiver
            self.userName = caregiver.name
            self.email = caregiver.email
            self.provider = caregiver.provider
        }
    }
    
    private func subscribeToRecords() {
        guard let babyId = selectedBaby?.id else { return }
        db.collection("babies").document(babyId.uuidString).collection("records")
            .order(by: "createdAt", descending: true)
            .snapshotPublisher()
            .map { snapshot in
                snapshot.documents.compactMap { try? $0.data(as: Record.self) }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.records, on: self)
            .store(in: &cancellables)
    }
    
    private func subscribeToNotes() {
        guard let babyId = selectedBaby?.id else { return }
        db.collection("babies").document(babyId.uuidString).collection("notes")
            .order(by: "createdAt", descending: true)
            .snapshotPublisher()
            .map { snapshot in
                snapshot.documents.compactMap { try? $0.data(as: Note.self) }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.notes, on: self)
            .store(in: &cancellables)
    }
    
    private func subscribeToVoiceRecords() {
        guard let babyId = selectedBaby?.id else { return }
        db.collection("babies").document(babyId.uuidString).collection("voiceRecords")
            .order(by: "createdAt", descending: true)
            .snapshotPublisher()
            .map { snapshot in
                snapshot.documents.compactMap { try? $0.data(as: VoiceRecord.self) }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.voiceRecords, on: self)
            .store(in: &cancellables)
    }
    
    private func loadCaregiver(uid: String) async -> Caregiver? {
        try? await Firestore.firestore().collection("users")
            .document(uid).getDocument().data(as: Caregiver.self)
    }
    
    private func loadBabies(from refs: [DocumentReference]) async -> [Baby] {
        await withTaskGroup(of: Baby?.self) { group in
            for ref in refs {
                group.addTask {
                    try? await ref.getDocument().data(as: Baby.self)
                }
            }
            var babies: [Baby] = []
            for await baby in group where baby != nil {
                babies.append(baby!)
            }
            return babies
        }
    }
    
    @MainActor
    func logout() {
        caregiver = nil
        babies = []
        selectedBaby = nil
        records = []
        voiceRecords = []
        notes = []
        userName = nil
        email = nil
        provider = nil
    }
    
    // 회원탈퇴 시 회원 데이터 삭제
    func deleteUserData(uid: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let document = try await userRef.getDocument()
        
        guard document.exists, let caregiver = try? document.data(as: Caregiver.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 데이터를 찾을 수 없거나 디코딩 실패"])
        }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for babyRef in caregiver.babies {
                group.addTask {
                    try await babyRef.delete()
                    let babyId = babyRef.documentID
                    let collections = ["records", "notes", "voiceRecords"]
                    for collection in collections {
                        let querySnapshot = try await db.collection("babies").document(babyId).collection(collection).getDocuments()
                        for document in querySnapshot.documents {
                            try await document.reference.delete()
                        }
                    }
                }
            }
            try await group.waitForAll()
        }
        try await userRef.delete()
        await logout()
        
        print("회원 데이터 및 관련 아기 데이터 삭제 성공")
    }
    
    // 아기 데이터 삭제
    func deleteBaby(_ baby: Baby) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 상태가 아닙니다."])
        }
        let userRef = db.collection("users").document(userId)
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                transaction.deleteDocument(babyRef)
                transaction.updateData(["babies": FieldValue.arrayRemove([babyRef])], forDocument: userRef)
                return nil
            }
            let collections = ["records", "notes", "voiceRecords"]
            for collection in collections {
                let querySnapshot = try await babyRef.collection(collection).getDocuments()
                for document in querySnapshot.documents {
                    try await document.reference.delete()
                }
            }
            await MainActor.run {
                self.babies.removeAll { $0.id == baby.id }
                if self.selectedBaby?.id == baby.id {
                    self.selectedBaby = self.babies.first
                }
            }
            print("아기 데이터 삭제 성공: \(baby.name)")
        } catch {
            print("아기 데이터 삭제 실패: \(error)")
            throw error
        }
    }
}
