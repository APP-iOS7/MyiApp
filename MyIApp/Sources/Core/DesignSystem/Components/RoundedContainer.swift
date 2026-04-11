import SwiftUI

public struct RoundedContainer<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = DesignSystem.Spacing.itemSpacing,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content
        }
        .padding(DesignSystem.Spacing.defaultPadding)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(DesignSystem.Radius.card)
        .clipped()
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.backgroundPrimary
            .ignoresSafeArea()

        RoundedContainer {
            Text("아이템 1")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Divider()
                .padding(.horizontal)
            Text("아이템 2")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .padding()
    }
}
