import SwiftUI

public struct YearMonthPicker: View {
    @Binding var month: Date

    public init(month: Binding<Date>) {
        _month = month
    }

    private var yearRange: ClosedRange<Int> {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear - 3) ... (currentYear + 3)
    }

    public var body: some View {
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
}
