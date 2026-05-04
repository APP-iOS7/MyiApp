import DesignSystem
import SwiftUI

struct ActionChip: View {
    let label: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule().fill(Color.Semantic.primaryAction.opacity(Opacity.highlight))
            )
            .foregroundColor(.Semantic.primaryAction)
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
}
