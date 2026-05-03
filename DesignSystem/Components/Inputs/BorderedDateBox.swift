import SwiftUI

public struct BorderedDateBox: View {
    @Binding public var date: Date
    public let from: Date?
    public let to: Date?

    public init(date: Binding<Date>, from: Date? = nil, to: Date? = nil) {
        _date = date
        self.from = from
        self.to = to
    }

    public var body: some View {
        ZStack {
            HStack {
                Text(date.formatted(.dateTime.year(.twoDigits).month().day()))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundStyle(Color.Semantic.primaryAction)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.m)
                    .stroke(Color.Semantic.primaryAction)
            )

            picker
                .datePickerStyle(.compact)
                .labelsHidden()
                .blendMode(.destinationOver)
        }
    }

    @ViewBuilder
    private var picker: some View {
        switch (from, to) {
        case (nil, nil):
            DatePicker("", selection: $date, displayedComponents: .date)
        case (let from?, nil):
            DatePicker("", selection: $date, in: from..., displayedComponents: .date)
        case (nil, let to?):
            DatePicker("", selection: $date, in: ...to, displayedComponents: .date)
        case let (from?, to?):
            DatePicker("", selection: $date, in: from ... to, displayedComponents: .date)
        }
    }
}
