import DesignSystem
import Domain
import SwiftUI

public struct NoteView: View {
    public let baby: Baby?

    @State private var month: Date = Date()
    @State private var selected: Date = Date()

    public init(baby: Baby?) {
        self.baby = baby
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ScreenTitle("육아 수첩")

            CalendarGrid(
                month: month,
                selected: selected,
                onSelect: { selected = $0 }
            )

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
