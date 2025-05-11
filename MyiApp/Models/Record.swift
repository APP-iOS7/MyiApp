//
//  Record.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation

struct Record: Codable, Identifiable {
    var id: UUID
    var createdAt: Date
    var title: TitleCategory
    var detail: RecordDetail
    
    init(title: TitleCategory, detail: RecordDetail) {
        self.id = UUID()
        self.createdAt = Date()
        self.title = title
        self.detail = detail
    }
}

enum TitleCategory: String, Codable, CaseIterable {
    case formula        // 분유
    case babyFood       // 이유식
    case pumpedMilk     // 유축수유
    case breastfeeding  // 모유수유
    case diaper         // 기저귀
    case potty          // 배변
    case sleep          // 수면
    case heightWeight   // 키/몸무게
    case bath           // 목욕
    case snack          // 간식
    case health         // 건강관리
}

enum PoopType: String, Codable {
    case poop
    case pee
    case all
}

enum HealthCareType: Codable {
    case bodyTemperature(temperature: Double)
    case medicine(memo: String)
    case clinic(memo: String)
    case etc(memo: String)
}

enum RecordDetail: Codable {
    case mlAmount(Int)  // 분유, 이유식, 유축수유
    case breastfeeding(leftMinutes: Int, rightMinutes: Int)  // 모유수유
    case potty(type: PoopType) // 배변
    case sleep(start: Date, end: Date)  // 수면
    case heightWeight(height: Double, weight: Double) // 키/몸무게
    case snack(content: String) // 간식
    case healthCare(note: HealthCareType) // 건강관리
    case fixedEvent  // 기저귀, 목욕 (1회 고정)
}
