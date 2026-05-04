import DesignSystem
import SwiftUI

struct SelectableChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, Spacing.s)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule().fill(
                        isSelected
                            ? Color.Semantic.primaryAction
                            : Color.Semantic.primaryAction.opacity(Opacity.highlight)
                    )
                )
                .foregroundColor(isSelected ? .white : .Semantic.primaryAction)
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
}
