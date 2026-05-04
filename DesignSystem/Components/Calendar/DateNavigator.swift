import Shared
import SwiftUI

public struct DateNavigator: View {
    public enum Step {
        case days(Int)
        case month
    }

    @Binding var selectedDate: Date
    private let step: Step
    private let labelText: (Date) -> String

    public init(
        selectedDate: Binding<Date>,
        step: Step = .days(1),
        labelText: @escaping (Date) -> String = { $0.shortDateWithDayLabel() }
    ) {
        _selectedDate = selectedDate
        self.step = step
        self.labelText = labelText
    }

    public var body: some View {
        HStack {
            Button("이전", systemImage: "chevron.left") { advance(direction: -1) }

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

            Button("다음", systemImage: "chevron.right") { advance(direction: 1) }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(.primary)
    }

    private func advance(direction: Int) {
        switch step {
        case let .days(value):
            selectedDate = Calendar.current
                .date(byAdding: .day, value: value * direction, to: selectedDate) ?? selectedDate

        case .month:
            selectedDate = Calendar.current.date(byAdding: .month, value: direction, to: selectedDate) ?? selectedDate
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        DateNavigator(selectedDate: .constant(Date()))
        DateNavigator(selectedDate: .constant(Date()), step: .days(7)) {
            "주 시작 \($0.formatted(.dateTime.month().day()))"
        }
        DateNavigator(selectedDate: .constant(Date()), step: .month) {
            $0.formatted(.dateTime.year().month())
        }
    }
    .padding()
}
