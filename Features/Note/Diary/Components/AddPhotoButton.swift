import DesignSystem
import SwiftUI

struct AddPhotoButton: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            RoundedRectangle(cornerRadius: Radius.s)
                .strokeBorder(
                    Color.Semantic.primaryAction,
                    style: StrokeStyle(lineWidth: 1, dash: [4])
                )
                .frame(width: 100, height: 100)
                .overlay(
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: IconSize.l))
                        Text("사진 추가")
                            .font(.caption)
                    }
                    .foregroundColor(.Semantic.primaryAction)
                )
        }
        .buttonStyle(NoHighlightButtonStyle())
    }
}

#Preview {
    AddPhotoButton {}
        .padding()
}
