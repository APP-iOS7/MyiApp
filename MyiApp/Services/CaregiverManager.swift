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
            clearUserInfo()
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
                name: user.displayName?.isEmpty == false ? user.displayName : nil,
                email: user.email ?? "unknown@example.com",
                provider: user.providerData.first?.providerID ?? "unknown",
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
    private func clearUserInfo() {
        caregiver = nil
        babies = []
        selectedBaby = nil
        userName = nil
        email = nil
        provider = nil
    }
    
    // 회원탈퇴 시 회원 데이터 삭제
    func deleteUserData(uid: String) async throws {
        try await db.collection("users").document(uid).delete()
    }
}
