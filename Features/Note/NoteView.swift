import DesignSystem
import Domain
import SwiftUI

public struct NoteView: View {
    public let baby: Baby?

    @State private var month: Date = Date()
    @State private var selected: Date = Date()

    private var yearRange: ClosedRange<Int> {
        let birthYear = baby.map { Calendar.current.component(.year, from: $0.birthDate) }
        let currentYear = Calendar.current.component(.year, from: Date())
        return (birthYear ?? currentYear - 10) ... (currentYear + 10)
    }

    public init(baby: Baby?) {
        self.baby = baby
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                ScreenTitle("육아 수첩")

                SectionCard(spacing: Spacing.s) {
                    CalendarHeader(month: $month, yearRange: yearRange)
                    CalendarGrid(
                        month: month,
                        selected: selected,
                        onSelect: { selected = $0 }
                    )
                }
            }
            .padding(Spacing.m)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }
}

#Preview {
    NoteView(baby: nil)
}
