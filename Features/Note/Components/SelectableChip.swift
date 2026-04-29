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

#Preview {
    HStack(spacing: Spacing.xs) {
        SelectableChip(label: "없음", isSelected: false) {}
        SelectableChip(label: "10분 전", isSelected: true) {}
        SelectableChip(label: "1시간 전", isSelected: false) {}
    }
    .padding()
}
