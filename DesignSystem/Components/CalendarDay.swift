import Foundation

public struct CalendarDay: Identifiable, Hashable {
    public var id: Date { date }
    public let date: Date
    public let isCurrentMonth: Bool

    public init(date: Date, isCurrentMonth: Bool) {
        self.date = date
        self.isCurrentMonth = isCurrentMonth
    }

    public var dayNumber: Int { Calendar.current.component(.day, from: date) }
    public var weekday: Int { Calendar.current.component(.weekday, from: date) }
    public var isToday: Bool { Calendar.current.isDateInToday(date) }
}
