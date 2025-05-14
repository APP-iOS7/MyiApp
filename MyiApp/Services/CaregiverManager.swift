//
//  CaregiverManager.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

class CaregiverManager: ObservableObject {
    @Published var caregiver: Caregiver?
    @Published var babies: [Baby] = [] {
        didSet {
            if selectedBaby == nil && !babies.isEmpty {
                selectedBaby = babies[0]
            } else {
                print("선택된 아기가 없음. CaregiverManager를 봐야함.")
            }
        }
    }
    @Published var selectedBaby: Baby?
    private let db = Firestore.firestore()
    private var cancellables: Set<AnyCancellable> = []
    static let shared = CaregiverManager()
    
    private init() { }
    
    @MainActor
    func loadCaregiverInfo() async {
        guard let uid = AuthService.shared.user?.uid else { return }
        
        do {
            let userDoc = try await db.collection("users").document(uid).getDocument()
            if let babyRefs = userDoc.get("babies") as? [DocumentReference] {
                var loadedBabies: [Baby] = []
                
                for babyRef in babyRefs {
                    let babyDoc = try await babyRef.getDocument()
                    if let baby = try? babyDoc.data(as: Baby.self) {
                        loadedBabies.append(baby)
                    }
                }
                
                await MainActor.run {
                    self.babies = loadedBabies
                    self.caregiver = Caregiver(id: uid, babies: loadedBabies)
                }
            }
        } catch {
            print("케어기버 정보를 불러오는데 실패했습니다: \(error.localizedDescription)")
        }
        setupBinding()
    }
    
    //    func addBaby(_ baby: Baby) async throws {
    //        let babyRef = db.collection("babies").document(baby.id.uuidString)
    //        try babyRef.setData(from: baby)
    //
    //        guard let uid = AuthService.shared.user?.uid else { return }
    //        let userDocRef = db.collection("users").document(uid)
    //        try await userDocRef.setData([
    //            "babies": FieldValue.arrayUnion([babyRef])
    //        ], merge: true)
    //
    //        await loadCaregiverInfo()
    //    }
    //
    //    func removeBaby(_ baby: Baby) async throws {
    //        let babyRef = db.collection("babies").document(baby.id.uuidString)
    //        try await babyRef.delete()
    //
    //        guard let uid = AuthService.shared.user?.uid else { return }
    //        let userDocRef = db.collection("users").document(uid)
    //        try await userDocRef.setData([
    //            "babies": FieldValue.arrayRemove([babyRef])
    //        ], merge: true)
    //
    //        await loadCaregiverInfo()
    //    }
    
    @MainActor
    private func setupBinding() {
        if let babyId = selectedBaby?.id {
            let babyRef = db.collection("babies").document(babyId.uuidString)
            babyRef
                .snapshotPublisher()
                .receive(on: RunLoop.main)
                .tryMap { try $0.data(as: Baby.self) }
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("아기 정보를 가져오는데 실패했습니다: \(error.localizedDescription)")
                    }
                }, receiveValue: { baby in
                    self.selectedBaby = baby
                    print("setupBinding: selectedBaby updated \(baby.records.count)")
                })
                .store(in: &cancellables)
            
        }
    }
    
    func saveRecord(record: Record) {
        // 선택된 아기가 없는 경우 오류를 출력하고 종료합니다.
        guard let babyId = selectedBaby?.id else {
            print("오류: 선택된 아기가 없습니다.")
            return
        }
        
        let babyRef = db.collection("babies").document(babyId.uuidString)
        
        do {
            // Record 객체를 Firestore에 저장할 수 있는 Dictionary로 인코딩합니다.
            let recordData = try Firestore.Encoder().encode(record)
            
            // Baby.swift의 records 배열 필드에 새 레코드를 추가합니다.
            babyRef.updateData(["records": FieldValue.arrayUnion([recordData])])
                .sink { completion in
                    switch completion {
                        case .failure(let error):
                            print("레코드 저장 중 오류: \(error.localizedDescription)")
                        case .finished:
                            print("레코드 저장 완료.")
                    }
                } receiveValue: { _ in
                }
                .store(in: &cancellables)
            
        } catch {
            print("레코드 인코딩 오류: \(error.localizedDescription)")
        }
    }
}
