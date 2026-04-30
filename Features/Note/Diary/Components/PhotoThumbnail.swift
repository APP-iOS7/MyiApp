import DesignSystem
import SwiftUI

struct PhotoThumbnail: View {
    let onRemove: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: Radius.s)
            .fill(Color.gray.opacity(Opacity.track))
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: IconSize.l))
                    .foregroundColor(.Semantic.secondaryText)
            )
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: IconSize.s))
                        .foregroundStyle(.white, .black.opacity(Opacity.scrim))
                }
                .buttonStyle(NoHighlightButtonStyle())
                .padding(Spacing.xs)
            }
    }
}

#Preview {
    PhotoThumbnail {}
        .padding()
}
