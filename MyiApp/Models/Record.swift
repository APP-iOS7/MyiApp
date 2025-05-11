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
    // 분유, 이유식, 유축수유 양 (ml)
    var mlAmount: Int?
    // 모유수유: 좌/우 분유 수유 시간 (분)
    var breastfeedingLeftMinutes: Int?
    var breastfeedingRightMinutes: Int?
    // 배변 종류
    var pottyType: PoopType?
    // 수면: 시작 및 종료 시간
    var sleepStart: Date?
    var sleepEnd: Date?
    // 키/몸무게
    var height: Double?
    var weight: Double?
    // 간식 내용
    var snackContent: String?
    // 건강관리 세부 정보
    var bodyTemperature: Double?       // 체온 측정 값
    var medicineMemo: String?          // 약 투여 메모
    var clinicMemo: String?            // 병원 방문 메모
    var healthEtcMemo: String?         // 기타 건강관리 메모
    // 고정 이벤트 (기저귀, 목욕 등)
    var isFixedEvent: Bool?
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

