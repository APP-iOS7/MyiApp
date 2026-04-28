import DesignSystem
import Domain
import SwiftUI

extension CareEvent {
    var title: String {
        switch self {
        case .formula: "분유"
        case .babyFood: "이유식"
        case .pumpedMilk: "유축수유"
        case .breastfeeding: "모유수유"
        case .pee: "소변"
        case .poop: "대변"
        case .pottyAll: "대소변"
        case .sleep: "수면"
        case .bath: "목욕"
        case .snack: "간식"
        case .temperature: "체온"
        case .medicine: "투약"
        case .clinic: "병원"
        case .heightWeight: "키/몸무게"
        }
    }

    var icon: Image {
        switch self {
        case .formula: Image(Asset.Records.Normal.powderedMilk)
        case .babyFood: Image(Asset.Records.Normal.babyMeal)
        case .pumpedMilk: Image(Asset.Records.Normal.pumpedMilk)
        case .breastfeeding: Image(Asset.Records.Normal.breastFeeding)
        case .pee: Image(Asset.Records.Normal.pee)
        case .poop: Image(Asset.Records.Normal.poop)
        case .pottyAll: Image(Asset.Records.Normal.potty)
        case .sleep: Image(Asset.Records.Color.sleep)
        case .bath: Image(Asset.Records.Color.bath)
        case .snack: Image(Asset.Records.Color.snack)
        case .temperature: Image(Asset.Records.Normal.temperature)
        case .medicine: Image(Asset.Records.Normal.medicine)
        case .clinic: Image(Asset.Records.Color.clinic)
        case .heightWeight: Image(Asset.Records.Color.heightWeight)
        }
    }
}

extension CareEvent.Category {
    var label: String {
        switch self {
        case .feeding: "수유"
        case .potty:   "배변"
        case .sleep:   "수면"
        case .bath:    "목욕"
        case .snack:   "간식"
        case .vital:   "체온"
        case .medical: "의료"
        case .growth:  "성장"
        }
    }

    var hasChartFootprint: Bool {
        switch self {
        case .feeding, .potty, .sleep, .bath, .snack: true
        case .vital, .medical, .growth: false
        }
    }

    var tintColor: Color {
        switch self {
        case .feeding: .Semantic.feeding
        case .potty:   .Semantic.potty
        case .sleep:   .Semantic.sleep
        case .bath:    .Semantic.bath
        case .snack:   .Semantic.snack
        case .vital, .medical: .Semantic.health
        case .growth:  .Semantic.growth
        }
    }
}

extension CareRecord {
    var subtitleText: String {
        switch event {
        case let .babyFood(ml), let .formula(ml), let .pumpedMilk(ml):
            "\(ml)ml"
        case let .breastfeeding(left, right):
            "왼쪽 \(left)분, 오른쪽 \(right)분"
        case let .sleep(start, end):
            formatSleepRange(start: start, end: end)
        case let .temperature(celsius):
            String(format: "%.1f°C", celsius)
        case let .heightWeight(heightCm, weightKg):
            formatHeightWeight(heightCm: heightCm, weightKg: weightKg)
        case .bath, .pee, .poop, .pottyAll:
            content ?? "기록 완료"
        case .clinic, .medicine, .snack:
            content ?? "메모 없음"
        }
    }

    private func formatHeightWeight(heightCm: Double?, weightKg: Double?) -> String {
        var parts: [String] = []
        if let heightCm {
            parts.append("키 \(String(format: "%.1f", heightCm))cm")
        }
        if let weightKg {
            parts.append("몸무게 \(String(format: "%.2f", weightKg))kg")
        }
        return parts.isEmpty ? "미기록" : parts.joined(separator: ", ")
    }

    private func formatSleepRange(start: Date, end: Date?) -> String {
        let startTime = start.hourMinute24h
        guard let end else {
            return "\(startTime) - 미기록"
        }

        let endTime = end.hourMinute24h

        if Calendar.current.isDate(start, inSameDayAs: end) {
            return "\(startTime) - \(endTime)"
        }
        let dateStyle: Date.FormatStyle = .dateTime.month().day()
        return "\(start.formatted(dateStyle)) \(startTime) - \(end.formatted(dateStyle)) \(endTime)"
    }
}
