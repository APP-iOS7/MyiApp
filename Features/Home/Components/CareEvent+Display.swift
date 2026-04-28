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
        }
    }
}

extension CareEvent.Category {
    var tintColor: Color {
        switch self {
        case .feeding: .Semantic.feeding
        case .potty: .Semantic.potty
        case .sleep: .Semantic.sleep
        case .bath: .Semantic.bath
        case .snack: .Semantic.snack
        case .medical, .vital: .Semantic.secondaryText
        }
    }
}

extension CareRecord {
    /// 타임라인/리스트 행에서 보여줄 부제목.
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
        case .bath, .pee, .poop, .pottyAll:
            content ?? "기록 완료"
        case .clinic, .medicine, .snack:
            content ?? "메모 없음"
        }
    }

    private func formatSleepRange(start: Date, end: Date) -> String {
        let startTime = start.hourMinute24h
        let endTime = end.hourMinute24h

        if Calendar.current.isDate(start, inSameDayAs: end) {
            return "\(startTime) - \(endTime)"
        }
        let dateStyle: Date.FormatStyle = .dateTime.month().day()
        return "\(start.formatted(dateStyle)) \(startTime) - \(end.formatted(dateStyle)) \(endTime)"
    }
}
