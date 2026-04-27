import SwiftUI

public struct RowLabeledContentStyle: LabeledContentStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            configuration.content
        }
        .padding(.vertical, Spacing.s)
        .contentShape(Rectangle())
    }
}
