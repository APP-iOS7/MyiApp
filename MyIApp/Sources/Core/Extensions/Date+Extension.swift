import Foundation

extension Date {
    public func to24HourTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    public func formattedKoreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "MM월 dd일 '(오늘)'"
        } else {
            formatter.dateFormat = "MM월 dd일 (E)"
        }

        return formatter.string(from: self)
    }

    public func formattedFullKoreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 (E)"
        return formatter.string(from: self)
    }

    public func replacingDate(with date: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: self)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

        var newComponents = DateComponents()
        newComponents.year = dateComponents.year
        newComponents.month = dateComponents.month
        newComponents.day = dateComponents.day
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        newComponents.second = timeComponents.second
        newComponents.nanosecond = timeComponents.nanosecond

        return calendar.date(from: newComponents) ?? self
    }
}
