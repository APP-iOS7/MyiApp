import SwiftUI

public struct CalendarHeader: View {
    @Binding var month: Date
    @State private var showMonthPicker = false

    public init(month: Binding<Date>) {
        self._month = month
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
                yearMonthPicker
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

    private var yearMonthPicker: some View {
        HStack(spacing: 0) {
            Picker("연도", selection: yearBinding) {
                ForEach(yearRange, id: \.self) { year in
                    Text(verbatim: "\(year)년").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Picker("월", selection: monthBinding) {
                ForEach(1 ... 12, id: \.self) { monthNumber in
                    Text(verbatim: "\(monthNumber)월").tag(monthNumber)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .padding(Spacing.m)
    }

    private var yearRange: ClosedRange<Int> {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear - 10) ... (currentYear + 10)
    }

    private var yearBinding: Binding<Int> {
        Binding(
            get: { Calendar.current.component(.year, from: month) },
            set: { newYear in setMonth(year: newYear, month: monthNumber) }
        )
    }

    private var monthBinding: Binding<Int> {
        Binding(
            get: { Calendar.current.component(.month, from: month) },
            set: { newMonth in setMonth(year: yearNumber, month: newMonth) }
        )
    }

    private var yearNumber: Int { Calendar.current.component(.year, from: month) }
    private var monthNumber: Int { Calendar.current.component(.month, from: month) }

    private func setMonth(year: Int, month newMonth: Int) {
        var components = DateComponents()
        components.year = year
        components.month = newMonth
        components.day = 1
        if let new = Calendar.current.date(from: components) {
            month = new
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
    CalendarHeader(month: $month)
        .padding(Spacing.m)
}
