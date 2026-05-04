import SwiftUI

public struct CalendarGrid: View {
    public let month: Date
    @Binding public var selected: Date
    public let datesWithIndicator: Set<Date>

    public init(
        month: Date,
        selected: Binding<Date>,
        datesWithIndicator: Set<Date> = []
    ) {
        self.month = month
        _selected = selected
        self.datesWithIndicator = datesWithIndicator
    }

    public var body: some View {
        VStack(spacing: Spacing.s) {
            weekdayHeader
            daysGrid
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(makeOrderedWeekdays(), id: \.weekday) { item in
                Text(item.symbol)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(item.color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }

    private var daysGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        return LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(makeDays(for: month)) { day in
                CalendarDayCell(
                    day: day,
                    isSelected: Calendar.current.isDate(day.date, inSameDayAs: selected),
                    hasIndicator: hasIndicator(on: day.date)
                )
                .contentShape(Rectangle())
                .onTapGesture { selected = day.date }
            }
        }
    }

    private func makeDays(for month: Date) -> [CalendarDay] {
        let calendar = Calendar.current
        let monthComponents = calendar.dateComponents([.year, .month], from: month)
        guard let firstOfMonth = calendar.date(from: monthComponents) else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        var leadingOffset = weekdayOfFirst - calendar.firstWeekday
        if leadingOffset < 0 { leadingOffset += 7 }
        guard let gridStart = calendar.date(byAdding: .day, value: -leadingOffset, to: firstOfMonth) else { return [] }

        return (0 ..< 42).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: gridStart)
                ?? gridStart
            return CalendarDay(
                date: calendar.startOfDay(for: date),
                isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month)
            )
        }
    }

    private func makeOrderedWeekdays() -> [(weekday: Int, symbol: String, color: Color)] {
        let calendar = Calendar.current
        let symbols = calendar.veryShortWeekdaySymbols
        return (0 ..< 7).map { offset in
            let weekday = ((calendar.firstWeekday - 1 + offset) % 7) + 1
            let color: Color = switch weekday {
            case 1: .red
            case 7: .blue
            default: .primary
            }
            return (weekday: weekday, symbol: symbols[weekday - 1], color: color)
        }
    }

    private func hasIndicator(on date: Date) -> Bool {
        let calendar = Calendar.current
        let target = calendar.startOfDay(for: date)
        return datesWithIndicator.contains { calendar.isDate($0, inSameDayAs: target) }
    }
}

#Preview("Calendar") {
    @Previewable @State var selected = Date()
    VStack {
        CalendarGrid(
            month: Date(),
            selected: $selected,
            datesWithIndicator: [
                Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            ]
        )
        .padding(Spacing.m)
        Spacer()
    }
    .background(Color.Semantic.screenBackground)
}
