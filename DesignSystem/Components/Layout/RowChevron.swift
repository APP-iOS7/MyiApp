import SwiftUI

public struct RowChevron: View {
    private let isExpanded: Bool?

    public init(isExpanded: Bool? = nil) {
        self.isExpanded = isExpanded
    }

    public var body: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.Semantic.secondaryText)
            .rotationEffect(.degrees(isExpanded == true ? 90 : 0))
    }
}
