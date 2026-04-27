import SwiftUI

public struct IconLabelStyle: LabelStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .frame(width: IconSize.l, height: IconSize.l)
            configuration.title
                .foregroundColor(.Semantic.secondaryText)
                .padding(.leading, Spacing.xs)
        }
    }
}
