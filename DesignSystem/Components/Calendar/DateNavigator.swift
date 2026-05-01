import Shared
import SwiftUI

public struct DateNavigator: View {
    @Binding var selectedDate: Date
    private let stepDays: Int
    private let labelText: (Date) -> String

    public init(
        selectedDate: Binding<Date>,
        stepDays: Int = 1,
        labelText: @escaping (Date) -> String = { $0.shortDateWithDayLabel() }
    ) {
        _selectedDate = selectedDate
        self.stepDays = stepDays
        self.labelText = labelText
    }

    public var body: some View {
        HStack {
            Button("이전", systemImage: "chevron.left") { addDays(-stepDays) }

            Spacer()

            Label(labelText(selectedDate), systemImage: "calendar")
                .font(.headline)
                .labelStyle(.titleAndIcon)
                .overlay {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .blendMode(.destinationOver)
                }

            Spacer()

            Button("다음", systemImage: "chevron.right") { addDays(stepDays) }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(.primary)
    }

    private func addDays(_ value: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
    }
}

#Preview {
    VStack(spacing: 24) {
        DateNavigator(selectedDate: .constant(Date()))
        DateNavigator(selectedDate: .constant(Date()), stepDays: 7) {
            "주 시작 \($0.formatted(.dateTime.month().day()))"
        }
    }
    .padding()
}
