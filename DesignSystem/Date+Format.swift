import Foundation

extension Date {
    /// "오늘"/"어제"/"내일" 같은 상대 일자 명. 그 외에는 nil.
    public var relativeDayName: String? {
        let cal = Calendar.current
        guard cal.isDateInToday(self)
                || cal.isDateInYesterday(self)
                || cal.isDateInTomorrow(self) else { return nil }

        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(
            for: cal.startOfDay(for: self),
            relativeTo: cal.startOfDay(for: Date())
        )
    }

    /// "11월 28일 (오늘)" / "11월 30일 (토)" 형태로 포맷
    public func shortDateWithDayLabel() -> String {
        let monthDay = formatted(.dateTime.month().day())
        let label = relativeDayName ?? formatted(.dateTime.weekday(.abbreviated))
        return "\(monthDay) (\(label))"
    }
}
