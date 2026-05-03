import SwiftUI

public struct SummaryRow: View {
    public let title: String
    public let value: String
    public let detail: String?

    public init(title: String, value: String, detail: String? = nil) {
        self.title = title
        self.value = value
        self.detail = detail
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.Semantic.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            if let detail {
                Text("·")
                    .foregroundStyle(Color.Semantic.secondaryText)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color.Semantic.secondaryText)
            }
        }
    }
}
