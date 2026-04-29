import SwiftUI

public struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let hasIndicator: Bool

    public init(day: CalendarDay, isSelected: Bool, hasIndicator: Bool) {
        self.day = day
        self.isSelected = isSelected
        self.hasIndicator = hasIndicator
    }

    public var body: some View {
        VStack(spacing: Spacing.s) {
            Text("00")
                .font(.body.monospacedDigit())
                .hidden()
                .overlay {
                    Text("\(day.dayNumber)")
                        .font(.body.monospacedDigit())
                        .foregroundColor(textColor)
                }
                .padding(Spacing.s)
                .background(Circle().fill(backgroundFill))

            Circle()
                .fill(hasIndicator ? Color.Semantic.primaryAction : .clear)
                .frame(width: CalendarLayout.indicatorSize, height: CalendarLayout.indicatorSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .opacity(day.isCurrentMonth ? 1 : CalendarLayout.outOfMonthOpacity)
    }

    private var textColor: Color {
        if isSelected { return .white }
        if day.weekday == 1 { return .red }
        if day.weekday == 7 { return .blue }
        return .primary
    }

    private var backgroundFill: Color {
        if isSelected { return Color.Semantic.primaryAction }
        if day.isToday { return Color.Semantic.primaryAction.opacity(CalendarLayout.todayBackgroundOpacity) }
        return .clear
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
    let saturday = calendar.date(byAdding: .day, value: 6, to: sunday) ?? today
    let previousMonth = calendar.date(byAdding: .month, value: -1, to: today) ?? today

    HStack(spacing: Spacing.m) {
        CalendarDayCell(
            day: CalendarDay(date: today, isCurrentMonth: true),
            isSelected: false,
            hasIndicator: false
        )
        CalendarDayCell(
            day: CalendarDay(date: today, isCurrentMonth: true),
            isSelected: true,
            hasIndicator: true
        )
        CalendarDayCell(
            day: CalendarDay(date: sunday, isCurrentMonth: true),
            isSelected: false,
            hasIndicator: true
        )
        CalendarDayCell(
            day: CalendarDay(date: saturday, isCurrentMonth: true),
            isSelected: false,
            hasIndicator: false
        )
        CalendarDayCell(
            day: CalendarDay(date: previousMonth, isCurrentMonth: false),
            isSelected: false,
            hasIndicator: false
        )
    }
    .padding()
    .background(Color.Semantic.screenBackground)
}
