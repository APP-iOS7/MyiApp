import Foundation

/// CareRecord 배열에서 날짜 기반으로 통계를 집계하는 유틸리티
public enum CareRecordAggregator {
    // MARK: - Filtering

    /// 특정 날짜에 해당하는 레코드 필터링
    public static func records(
        _ records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> [CareRecord] {
        records.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }

    /// 카테고리별 횟수
    public static func count(
        of category: CareEvent.Category,
        in records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> Int {
        records.filter {
            $0.event.category == category && calendar.isDate($0.createdAt, inSameDayAs: date)
        }.count
    }

    // MARK: - Feeding

    /// 수유/이유식 합산 횟수
    public static func feedingCount(
        in records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> Int {
        count(of: .feeding, in: records, on: date, calendar: calendar)
    }

    /// ml 총량 (분유/이유식/유축수유)
    public static func totalMl(
        in records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> Int {
        records
            .filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
            .reduce(0) { total, record in
                switch record.event {
                case let .formula(ml), let .babyFood(ml), let .pumpedMilk(ml):
                    return total + ml
                default:
                    return total
                }
            }
    }

    /// 모유수유 총 시간 (분)
    public static func totalBreastfeedingMinutes(
        in records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> Int {
        records
            .filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
            .reduce(0) { total, record in
                if case let .breastfeeding(left, right) = record.event {
                    return total + left + right
                }
                return total
            }
    }

    // MARK: - Potty

    /// 소변/대변 횟수
    public static func pottyCount(
        in records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> (pee: Int, poop: Int) {
        var pee = 0
        var poop = 0
        for record in records {
            guard calendar.isDate(record.createdAt, inSameDayAs: date) else { continue }
            switch record.event {
            case .pee: pee += 1
            case .poop: poop += 1
            case .pottyAll: pee += 1; poop += 1
            default: continue
            }
        }
        return (pee, poop)
    }

    // MARK: - Sleep

    /// 수면 총 시간 (분) — 선택 날짜 범위에 맞게 클리핑
    public static func totalSleepMinutes(
        in records: [CareRecord],
        on date: Date,
        calendar: Calendar = .current
    ) -> Int? {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }

        let total = records
            .compactMap { record -> Int? in
                guard case let .sleep(start, end) = record.event, let end else { return nil }
                let clipped = max(start, startOfDay)
                let clippedEnd = min(end, endOfDay)
                let interval = clippedEnd.timeIntervalSince(clipped)
                return interval > 0 ? Int(interval / 60) : nil
            }
            .reduce(0, +)

        return total >= 0 ? total : nil
    }
}
