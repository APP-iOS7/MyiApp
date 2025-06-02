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
    @Published var birthDate: Date? = Calendar.current.startOfDay(for: Date())
    @Published var gender: Gender?
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bloodType: BloodType?
    @Published var isRegistered: Bool = false
    @Published var birthDateRawText: String = ""
    @Published var shouldMoveToHeight: Bool = false
    @Published var errorMessage: String?
    @Published var isTimeSelectionEnabled: Bool = false
    
    func registerBaby() async {
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
            do {
                try await databaseService.saveBabyInfo(baby: baby)
                isRegistered = true
            } catch {
                errorMessage = error.localizedDescription
                isRegistered = false
            }
    }
}

