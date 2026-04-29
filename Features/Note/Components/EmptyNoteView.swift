import DesignSystem
import SwiftUI

struct EmptyNoteView: View {
    var body: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "doc.text")
                .font(.system(size: IconSize.l))
                .foregroundColor(.Semantic.secondaryText)
            Text("기록이 없어요")
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.l)
    }
}

#Preview {
    EmptyNoteView()
}
