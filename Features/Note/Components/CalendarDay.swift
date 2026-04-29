import DesignSystem
import SwiftUI

struct CalendarDay: Identifiable, Hashable {
    var id: Date { date }
    let date: Date
    let isCurrentMonth: Bool

    var dayNumber: Int { Calendar.current.component(.day, from: date) }
    var weekday: Int { Calendar.current.component(.weekday, from: date) }
    var isToday: Bool { Calendar.current.isDateInToday(date) }
}
