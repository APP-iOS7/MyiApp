import DesignSystem
import SwiftUI

struct PhotoThumbnail: View {
    let data: Data
    let onRemove: () -> Void

    var body: some View {
        thumbnail
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: Radius.s))
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

    @ViewBuilder
    private var thumbnail: some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Color.gray.opacity(Opacity.track)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: IconSize.l))
                        .foregroundColor(.Semantic.secondaryText)
                )
        }
    }
}
