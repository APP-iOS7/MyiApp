import SwiftUI

public struct PlainDisclosureGroupStyle: DisclosureGroupStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Button {
                withAnimation { configuration.isExpanded.toggle() }
            } label: {
                LabeledContent {
                    RowChevron(isExpanded: configuration.isExpanded)
                } label: {
                    configuration.label
                }
                .labeledContentStyle(RowLabeledContentStyle())
            }
            .buttonStyle(NoHighlightButtonStyle())

            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}
