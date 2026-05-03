import SwiftUI

public struct SelectionPopup: View {
    public let title: String
    public let value: String

    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.Semantic.secondaryText)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(Spacing.s)
        .background(
            RoundedRectangle(cornerRadius: Radius.s)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.s)
                .stroke(Color.Semantic.secondaryText.opacity(Opacity.guide))
        )
    }
}
