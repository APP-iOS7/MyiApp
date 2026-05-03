import Foundation
import Shared

public enum DetailMode: String, CaseIterable, Hashable, Sendable {
    case daily = "일"
    case weekly = "주"
    case monthly = "월"

    public var previousLabel: String {
        switch self {
        case .daily: "어제"
        case .weekly: "지난주"
        case .monthly: "지난달"
        }
    }

    public func previousDate(from date: Date, calendar: Calendar = .current) -> Date {
        switch self {
        case .daily:
            calendar.date(byAdding: .day, value: -1, to: date) ?? date
        case .weekly:
            calendar.date(byAdding: .day, value: -7, to: date) ?? date
        case .monthly:
            calendar.date(byAdding: .month, value: -1, to: date) ?? date
        }
    }

    public func currentRange(of date: Date, calendar: Calendar = .current) -> Range<Date> {
        switch self {
        case .daily:
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return start ..< end
        case .weekly:
            var weekCalendar = calendar
            weekCalendar.firstWeekday = 2 // 월요일 시작
            let start = weekCalendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            let end = weekCalendar.date(byAdding: .day, value: 7, to: start) ?? start
            return start ..< end
        case .monthly:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
            return start ..< end
        }
    }

    public func previousRange(of date: Date, calendar: Calendar = .current) -> Range<Date> {
        currentRange(of: previousDate(from: date, calendar: calendar), calendar: calendar)
    }

    /// 현재 기간을 포함한 과거 N개 기간의 시작일들 (오래된 → 최신 순)
    public func trailingPeriodStarts(from date: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        let currentStart = currentRange(of: date, calendar: calendar).lowerBound
        return (0 ..< count).reversed().compactMap { offset in
            switch self {
            case .daily:
                calendar.date(byAdding: .day, value: -offset, to: currentStart)
            case .weekly:
                calendar.date(byAdding: .day, value: -7 * offset, to: currentStart)
            case .monthly:
                calendar.date(byAdding: .month, value: -offset, to: currentStart)
            }
        }
    }

    public func dateLabel(for date: Date) -> String {
        switch self {
        case .daily: date.shortDateWithDayLabel()
        case .weekly: date.weekRangeLabel()
        case .monthly: date.formatted(.dateTime.year().month())
        }
    }

    public func axisLabel(for periodStart: Date, calendar: Calendar = .current) -> String {
        switch self {
        case .daily:
            "\(calendar.component(.day, from: periodStart))"
        case .weekly:
            periodStart.formatted(.dateTime.month().day())
        case .monthly:
            "\(calendar.component(.month, from: periodStart))월"
        }
    }

    public init(from parentMode: StatisticFeature.Mode) {
        switch parentMode {
        case .daily: self = .daily
        case .weekly: self = .weekly
        }
    }
}
