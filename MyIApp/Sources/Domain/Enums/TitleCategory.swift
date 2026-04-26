import Foundation

public enum TitleCategory: String, Codable, CaseIterable, Sendable {
    case formula // 분유
    case babyFood // 이유식
    case pumpedMilk // 유축수유
    case breastfeeding // 모유수유
    case diaper // 기저귀
    case sleep // 수면
    case heightWeight // 키/몸무게
    case bath // 목욕
    case snack // 간식
    case temperature // 온도
    case medicine // 약
    case clinic // 병원/메모
    case poop // 대변
    case pee // 소변
    case pottyAll // 배변 전체
}
