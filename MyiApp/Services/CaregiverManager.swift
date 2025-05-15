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
                print("CaregiverManager: 선택된 아기가 없음. 봐야함.")
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
                }, receiveValue: { [weak self] baby in
                    self?.selectedBaby = baby
                    print("CaregiverManager: selectedBaby record updated \(baby.records.count)")
                })
                .store(in: &cancellables)
            
        }
    }
    
    func saveRecord(record: Record) {
        guard let babyId = selectedBaby?.id else {
            print("오류: 선택된 아기가 없습니다.")
            return
        }
        let babyRef = db.collection("babies").document(babyId.uuidString)
        babyRef.getDocument()
            .compactMap { try? $0.data(as: Baby.self) }
            .sink { completion in
                if case .failure(let error) = completion {
                    print("데이터 가져오기 오류: \(error.localizedDescription)")
                }
            } receiveValue: { baby in
                var updatedRecords = baby.records.filter { $0.id != record.id }
                updatedRecords.append(record)
                babyRef.updateData(["records": updatedRecords.map { try! Firestore.Encoder().encode($0) }])
                    .sink { completion in
                        switch completion {
                            case .failure(let error):
                                print("레코드 저장/업데이트 오류: \(error.localizedDescription)")
                            case .finished:
                                print("레코드 저장/업데이트 완료.")
                        }
                    } receiveValue: { _ in }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
    func deleteRecord(record: Record) {
        guard let babyId = selectedBaby?.id else {
            print("오류: 선택된 아기가 없습니다.")
            return
        }
        let babyRef = db.collection("babies").document(babyId.uuidString)
        babyRef.getDocument()
            .compactMap { try? $0.data(as: Baby.self) }
            .sink { completion in
                if case .failure(let error) = completion {
                    print("데이터 가져오기 오류: \(error.localizedDescription)")
                }
            } receiveValue: { baby in
                let updatedRecords = baby.records.filter { $0.id != record.id }
                babyRef.updateData(["records": updatedRecords.map { try! Firestore.Encoder().encode($0) }])
                    .sink { completion in
                        switch completion {
                            case .failure(let error):
                                print("레코드 삭제 오류: \(error.localizedDescription)")
                            case .finished:
                                print("레코드 삭제 완료.")
                        }
                    } receiveValue: { _ in }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
}
