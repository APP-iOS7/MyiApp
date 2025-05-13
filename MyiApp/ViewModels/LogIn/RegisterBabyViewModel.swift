//
//  RegisterBabyViewModel.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/13/25.
//

import SwiftUI

@MainActor
class RegisterBabyViewModel: ObservableObject {
    private let databaseService = DatabaseService.shared
    
    @Published var name: String = ""
    @Published var birthDate: Date? = nil
    @Published var gender: Gender? = nil
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bloodType: BloodType? = nil
    @Published var isRegistered: Bool = false
    
    // 등록 결과 메시지 등 필요시
    @Published var errorMessage: String? = nil
    
    func registerBaby() {
        guard let gender = gender,
              let bloodType = bloodType,
              let birthDate = birthDate,
              let heightValue = Double(height),
              let weightValue = Double(weight) else {
            errorMessage = "모든 정보를 입력해주세요."
            return
        }
        let baby = Baby(name: name,
                        birthDate: birthDate,
                        gender: gender,
                        height: heightValue,
                        weight: weightValue,
                        bloodType: bloodType)
        Task {
            do {
                try await databaseService.saveBabyInfo(baby: baby)
                isRegistered = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
