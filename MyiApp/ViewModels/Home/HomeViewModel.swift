//
//  HomeViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import SwiftUI
//import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var baby: Baby?
    @Published var records: [Record] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: GridItemCategory?
    @Published var recordToEdit: Record?
    @Published var showDeleteAlert: Bool = false
    @Published var recordToDelete: Record?
    @Published var isPresented: Bool = false

    var displaySharkImage: UIImage {
        guard let birthDate = baby?.birthDate else {
            return UIImage(resource: .sharkNewBorn)
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        guard let months = calendar.dateComponents([.month], from: birthDate, to: now).month,
              let days = calendar.dateComponents([.day], from: birthDate, to: now).day else {
            return UIImage(resource: .sharkNewBorn)
        }
        
        switch months {
        case 0 where days < 28:
                return UIImage(resource: .sharkNewBorn)
        case 0...11:
                return UIImage(resource: .sharkInfant)
        case 12...35:
                return UIImage(resource: .sharkToddler)
        default:
                return UIImage(resource: .sharkChild)
        }
    }
    let caregiverManager = CaregiverManager.shared
    var displayName: String {
        baby?.name ?? "loading..."
    }
    var displayGender: String {
        baby?.gender.rawValue == 1 ? "남아" : "여아"
    }
    var displayBirthDate: String {
        guard let baby else { return "알 수 없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: baby.birthDate)
    }
    var displayBloodType: String {
        guard let baby else { return "알 수 없음" }
        return "\(baby.bloodType.rawValue) 형"
    }
    var displayHeightWeight: String {
        guard let baby else { return "알 수 없음" }
        let heightText = String(format: "%.1f", baby.height)
        let weightText = String(format: "%.1f", baby.weight)
        
        return "\(heightText) cm / \(weightText) kg"
    }
    var displayDevelopmentalStage: String {
        guard let birthDate = baby?.birthDate else { return "알 수 없음" }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.month, .day], from: birthDate, to: now)
        
        guard let months = components.month,
              let days = components.day else {
            return "알 수 없음"
        }
        
        if months == 0 && days < 30 {
            return "신생아기"
        } else if months < 12 {
            return "영아기"
        } else if months < 36 {
            return "유아기"
        } else {
            return "아동기"
        }
    }
    var displayDayCount: String {
        let days = Calendar.current.dateComponents([.day], from: baby?.birthDate ?? Date(), to: Date()).day ?? 0
        return "+ \(days + 1)일"
    }
    var filteredRecords: [Record] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        let filtered = records.filter { record in
            return record.createdAt >= startOfDay && record.createdAt < endOfDay
        }
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    var recentMeal: Record? {
        let mealCategories: [TitleCategory] = [.formula, .babyFood, .pumpedMilk, .breastfeeding]
        return records
            .filter { mealCategories.contains($0.title) }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }
    var recentPotty: Record? {
        let pottyCategories: [TitleCategory] = [.poop, .pee, .pottyAll]
        return records
            .filter { pottyCategories.contains($0.title) }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }
    var recentSnack: Record? {
        return records
            .filter { $0.title == .snack }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }
    var recentHealth: Record? {
        let healthCategories: [TitleCategory] = [.temperature, .medicine, .clinic]
        return records
            .filter { healthCategories.contains($0.title) }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }
    
    init() {
        CaregiverManager.shared.$selectedBaby
            .assign(to: &$baby)
        CaregiverManager.shared.$records
            .assign(to: &$records)
    }
    
    func gridItemDidTap(title: TitleCategory) {
        switch title {
            case .breastfeeding:
                if let recentMeal {
                    let newRecord = Record(
                        id: UUID(),
                        createdAt: Date(),
                        title: recentMeal.title,
                        mlAmount: recentMeal.mlAmount,
                        breastfeedingLeftMinutes: recentMeal.breastfeedingLeftMinutes,
                        breastfeedingRightMinutes: recentMeal.breastfeedingRightMinutes
                    )
                    saveRecord(record: newRecord)
                } else {
                    saveRecord(record: Record(title: .breastfeeding))
                }
            case .diaper:
                saveRecord(record: Record(title: .diaper))
            case .pee:
                if let recentPotty = recentPotty {
                    let newRecord = Record(
                        id: UUID(),
                        createdAt: Date(),
                        title: recentPotty.title
                    )
                    saveRecord(record: newRecord)
                } else {
                    saveRecord(record: Record(title: .pee))
                }
            case .sleep:
                saveRecord(record: Record(title: .sleep, sleepStart: Date()))
            case .heightWeight:
                saveRecord(record: Record(title: .heightWeight))
            case .bath:
                saveRecord(record: Record(title: .bath))
            case .snack:
                if let recentSnack = recentSnack {
                    let newRecord = Record(
                        id: UUID(),
                        createdAt: Date(),
                        title: recentSnack.title,
                        content: recentSnack.content
                    )
                    saveRecord(record: newRecord)
                } else {
                    saveRecord(record: Record(title: .snack))
                }
            case .temperature:
                if let recentHealth = recentHealth {
                    let newRecord = Record(
                        id: UUID(),
                        createdAt: Date(),
                        title: recentHealth.title,
                        temperature: recentHealth.temperature,
                        content: recentHealth.content
                    )
                    saveRecord(record: newRecord)
                } else {
                    saveRecord(record: Record(title: .temperature, temperature: 36.5))
                }
            default:
                print(title)
        }
        
    }
    
    func saveRecord(record: Record) {
        guard let baby else { return }
        var recordToSave = record
        recordToSave.createdAt = Date().replacingDate(with: selectedDate)
        let _ = Firestore.firestore().collection("babies").document(baby.id.uuidString).collection("records").document(record.id.uuidString).setData(from: recordToSave)
    }
    
    func babyChangeButtonDidTap(baby: Baby) {
        
    }
    
    func deleteRecord(_ record: Record, completion: ((Error?) -> Void)? = nil) {
        guard let baby else { return }
        Firestore.firestore().collection("babies").document(baby.id.uuidString).collection("records").document(record.id.uuidString).delete { error in
            if let error = error {
                print("Error deleting record: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("Record successfully deleted")
                completion?(nil)
            }
        }
    }
    
    func showDeleteConfirmation(for record: Record) {
        recordToDelete = record
        showDeleteAlert = true
    }
    
    func cancelDelete() {
        recordToDelete = nil
        showDeleteAlert = false
    }
    
    func confirmDelete() {
        if let record = recordToDelete {
            deleteRecord(record) { error in
                if error == nil {
                    self.recordToDelete = nil
                    self.showDeleteAlert = false
                }
            }
        }
    }
    
    func updateSelectedDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func toggleBabyFullScreenCard() {
        isPresented.toggle()
    }
}


