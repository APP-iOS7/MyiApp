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

    /// 24시 형식 "HH:mm" (로케일과 무관하게 AM/PM 미표시)
    public var hourMinute24h: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    /// 13:30 → 13.5 (소수점 시간)
    public var hourDecimal: Double {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return Double(components.hour ?? 0) + Double(components.minute ?? 0) / 60
    }

    /// "11월 24일 ~ 11월 30일" 형태로 월요일 시작 주 범위 반환.
    public func weekRangeLabel() -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // 월요일
        let weekStart = cal.dateInterval(of: .weekOfYear, for: self)?.start ?? self
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) ?? self
        let style: Date.FormatStyle = .dateTime.month().day()
        return "\(weekStart.formatted(style)) ~ \(weekEnd.formatted(style))"
    }

    /// birthDate 기준 "X개월 Y일" 경과 텍스트
    public func ageText(from birthDate: Date, calendar: Calendar = .current) -> String {
        let months = calendar.dateComponents([.month], from: birthDate, to: self).month ?? 0
        let monthDate = calendar.date(byAdding: .month, value: months, to: birthDate) ?? self
        let days = (calendar.dateComponents([.day], from: monthDate, to: self).day ?? 0) + 1
        return "\(months)개월 \(days)일"
    }
}
