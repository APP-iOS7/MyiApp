import SwiftUI

public struct CheckmarkRow: View {
    private let title: String
    private let font: Font
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        title: String,
        font: Font = .title3,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(font)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title2)
                .foregroundColor(isSelected ? Color.Semantic.primaryAction : Color.Semantic.secondaryText)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}
