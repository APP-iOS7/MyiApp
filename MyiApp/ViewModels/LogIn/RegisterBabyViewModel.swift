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
    @Published var birthDate: Date?
    @Published var gender: Gender?
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bloodType: BloodType?
    @Published var isRegistered: Bool = false
    @Published var birthDateRawText: String = "" 
    
    // 등록 결과 메시지 등 필요시
    @Published var errorMessage: String?
    
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
    
    func formatBirthDate(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        switch digits.count {
        case 1...4:
            return "\(digits)/"
        case 5...6:
            let year = digits.prefix(4)
            let month = digits.dropFirst(4)
            return "\(year)/\(month)/"
        case 7...8:
            let year = digits.prefix(4)
            let month = digits.dropFirst(4).prefix(2)
            let day = digits.dropFirst(6)
            return "\(year)/\(month)/\(day)"
        default:
            return ""
        }
    }
    
    // 입력값을 Date로 파싱
    func parseBirthDate() {
            guard birthDateRawText.count == 8 else {
                birthDate = nil
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            if let date = formatter.date(from: birthDateRawText) {
                birthDate = date
            } else {
                birthDate = nil
            }
        }

        // 포맷된 문자열 반환
        var formattedBirthDateText: String {
            let raw = birthDateRawText
            guard raw.count == 8 else { return raw }

            let year = raw.prefix(4)
            let month = raw.dropFirst(4).prefix(2)
            let day = raw.suffix(2)
            return "\(year)/\(month)/\(day)"
        }

        // TextField에서 set할 때 호출
        func updateBirthDateText(from newValue: String) {
            let filtered = newValue.filter { $0.isNumber }
            birthDateRawText = String(filtered.prefix(8))
            parseBirthDate()
        }
    }

