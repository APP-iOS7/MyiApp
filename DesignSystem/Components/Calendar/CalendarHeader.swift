import SwiftUI

public struct CalendarHeader: View {
    @Binding var month: Date
    let yearRange: ClosedRange<Int>
    @State private var showMonthPicker = false

    public init(month: Binding<Date>, yearRange: ClosedRange<Int>) {
        self._month = month
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
            .buttonStyle(NoHighlightButtonStyle())

            Spacer()

            Button(action: { showMonthPicker = true }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: IconSize.s))
                        .foregroundColor(.primary)
                    Text(monthTitle)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())
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
            .buttonStyle(NoHighlightButtonStyle())
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("yMMMM")
        return formatter.string(from: month)
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
    let currentYear = Calendar.current.component(.year, from: Date())
    CalendarHeader(month: $month, yearRange: (currentYear - 10) ... (currentYear + 10))
        .padding(Spacing.m)
}
