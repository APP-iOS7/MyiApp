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
    @Published var baby: Baby = CaregiverManager.shared.selectedBaby!
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: GridItemCategory?
    @Published var isFlipped = false
    private var cancellables = Set<AnyCancellable>()
    private let caregiverManager = CaregiverManager.shared
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
    
}
