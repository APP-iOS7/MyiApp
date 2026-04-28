import DesignSystem
import Domain
import SwiftUI

public struct NoteView: View {
    public let baby: Baby?

    public init(baby: Baby?) {
        self.baby = baby
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ScreenTitle("육아 수첩")

            Text("준비 중")
                .font(.body)
                .foregroundColor(.Semantic.secondaryText)

            Spacer()
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }
}

#Preview {
    NoteView(baby: nil)
}
