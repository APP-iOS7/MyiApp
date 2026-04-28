import SwiftUI

public struct DayNavigator: View {
    @Binding var selectedDate: Date

    public init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
    }

    public var body: some View {
        HStack {
            Button("이전 날짜", systemImage: "chevron.left") { addDays(-1) }

            Spacer()

            Label(selectedDate.shortDateWithDayLabel(), systemImage: "calendar")
                .font(.headline)
                .labelStyle(.titleAndIcon)
                .overlay {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .blendMode(.destinationOver)
                }

            Spacer()

            Button("다음 날짜", systemImage: "chevron.right") { addDays(1) }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(.primary)
    }

    private func addDays(_ value: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
    }
}

#Preview {
    DayNavigator(selectedDate: .constant(Date()))
        .padding()
}
