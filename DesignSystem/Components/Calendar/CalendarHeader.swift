import SwiftUI

public struct CalendarHeader: View {
    @Binding var month: Date
    @Binding var selected: Date
    let yearRange: ClosedRange<Int>
    @State private var showMonthPicker = false

    public init(
        month: Binding<Date>,
        selected: Binding<Date>,
        yearRange: ClosedRange<Int>
    ) {
        _month = month
        _selected = selected
        self.yearRange = yearRange
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: IconSize.m))
                    .foregroundColor(.primary)
                    .frame(width: IconSize.xl, height: IconSize.xl)
            }

            Spacer()

            Button(action: { showMonthPicker = true }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: IconSize.s))
                        .foregroundColor(.primary)
                    Text(month, format: .dateTime.year().month())
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                }
            }
            .popover(isPresented: $showMonthPicker) {
                YearMonthPicker(month: $month, yearRange: yearRange)
                    .presentationCompactAdaptation(.popover)
            }

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: IconSize.m))
                    .foregroundColor(.primary)
                    .frame(width: IconSize.xl, height: IconSize.xl)
            }

            Spacer()

            Button(action: {
                let today = Date()
                month = today
                selected = today
            }) {
                Text("오늘")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .padding(.vertical, Spacing.s)
                    .padding(.horizontal, Spacing.m)
                    .overlay(Capsule().stroke(Color.primary, lineWidth: 1))
            }
            .disabled(isSelectedToday)
            .opacity(isSelectedToday ? Opacity.disabled : 1)
        }
        .buttonStyle(NoHighlightButtonStyle())
    }

    private var isSelectedToday: Bool {
        Calendar.current.isDateInToday(selected)
    }

    private func previousMonth() {
        if let new = Calendar.current.date(byAdding: .month, value: -1, to: month) {
            month = new
        }
    }

    private func nextMonth() {
        if let new = Calendar.current.date(byAdding: .month, value: 1, to: month) {
            month = new
        }
    }
}

#Preview {
    @Previewable @State var month = Date()
    @Previewable @State var selected = Date()
    let currentYear = Calendar.current.component(.year, from: Date())
    CalendarHeader(
        month: $month,
        selected: $selected,
        yearRange: (currentYear - 10) ... (currentYear + 10)
    )
    .padding(Spacing.m)
}
