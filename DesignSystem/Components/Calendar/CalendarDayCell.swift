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
        .opacity(day.isCurrentMonth || isSelected ? 1 : Opacity.dimmed)
    }

    private var textColor: Color {
        if isSelected { return .white }
        if day.weekday == 1 { return .red }
        if day.weekday == 7 { return .blue }
        return .primary
    }

    private var backgroundFill: Color {
        if isSelected { return Color.Semantic.primaryAction }
        if day.isToday { return Color.Semantic.primaryAction.opacity(Opacity.highlight) }
        return .clear
    }
}
