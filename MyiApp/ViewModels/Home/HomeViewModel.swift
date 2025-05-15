//
//  HomeViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var baby: Baby!
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: GridItemCategory?
    @Published var recordToEdit: Record?
    @Published var isFlipped = false
    
    private var cancellables = Set<AnyCancellable>()
    var displayName: String {
        baby.name
    }
    var displayGender: String {
        baby.gender.rawValue == 1 ? "남자" : "여자"
    }
    var displayBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: baby.birthDate)
    }
    var displayMonthDay: String {
        let diff = Calendar.current.dateComponents([.month, .day], from: baby.birthDate, to: Date())
        return "\(diff.month ?? 0)개월 \(diff.day ?? 0)일"
    }
    var displayDayCount: String {
        let days = Calendar.current.dateComponents([.day], from: baby.birthDate, to: Date()).day ?? 0
        return "\(days + 1)일"
    }
    var filteredRecords: [Record] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        let filtered = baby.records.filter { record in
            return record.createdAt >= startOfDay && record.createdAt < endOfDay
        }
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    
    init() {
        self.baby = CaregiverManager.shared.selectedBaby!
        CaregiverManager.shared.$selectedBaby
            .assign(to: &$baby)
    }
}
