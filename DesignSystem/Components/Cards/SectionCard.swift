import SwiftUI

public struct SectionCard<Content: View>: View {
    private let title: String?
    private let spacing: CGFloat
    private let content: Content

    public init(
        title: String? = nil,
        spacing: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.Semantic.sectionHeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, Spacing.m)
            }
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.m)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
    }
}
