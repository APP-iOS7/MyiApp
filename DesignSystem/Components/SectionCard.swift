import SwiftUI

public struct SectionCard<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = Spacing.l, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
    }
}

#Preview {
    SectionCard {
        Text("제목").font(.title.bold())
        Text("본문").font(.body)
    }
    .padding()
}
