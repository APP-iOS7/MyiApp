//
//  HomeViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var baby: Baby?
    @Published var records: [Record] = []
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: GridItemCategory?
    @Published var recordToEdit: Record?
    let caregiverManager = CaregiverManager.shared
    private var cancellables = Set<AnyCancellable>()
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
        let heightText = String(format: "%.0f", baby.height)
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
    var recentHeightWeight: Record? {
        return records
            .filter { $0.title == .heightWeight }
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
    
    func saveRecord(record: Record) {
        guard let baby else { return }
        let _ = Firestore.firestore().collection("babies").document(baby.id.uuidString).collection("records").document(record.id.uuidString).setData(from: record)
    }
    
    func babyChangeButtonDidTap(baby: Baby) {
        
    }
}
