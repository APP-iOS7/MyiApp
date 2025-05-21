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
    private var cancellables = Set<AnyCancellable>()
    var displayName: String {
        baby?.name ?? "loading..."
    }
    var displayGender: String {
        baby?.gender.rawValue == 1 ? "남아" : "여아"
    }
    var displayBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: baby?.birthDate ?? Date())
    }
    var displayMonthDay: String {
        let diff = Calendar.current.dateComponents([.month, .day], from: baby?.birthDate ?? Date(), to: Date())
        return "\(diff.month ?? 0)개월 \(diff.day ?? 0)일"
    }
    var displayDayCount: String {
        let days = Calendar.current.dateComponents([.day], from: baby?.birthDate ?? Date(), to: Date()).day ?? 0
        return "\(days + 1)일"
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
        _ = Firestore.firestore().collection("babies").document(baby.id.uuidString).collection("records").document(record.id.uuidString).setData(from: record)
    }
}
