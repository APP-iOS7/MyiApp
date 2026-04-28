import DesignSystem
import SwiftUI

struct CareEntryGrid: View {
    let onSelect: (HomeCareEntry) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.m), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.m) {
            ForEach(HomeCareEntry.allCases, id: \.self) { entry in
                Button { onSelect(entry) } label: { EntryIcon(entry: entry) }
                    .buttonStyle(.plain)
            }
        }
    }
}

private struct EntryIcon: View {
    let entry: HomeCareEntry

    var body: some View {
        VStack(spacing: Spacing.xs) {
            image
                .resizable()
                .scaledToFit()
                .padding(Spacing.s)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .fill(Color.Semantic.screenBackground)
                )

            Text(entry.label)
                .font(.footnote)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }

    private var image: Image {
        switch entry {
        case .feeding: Image(Asset.Records.Color.meal)
        case .potty: Image(Asset.Records.Color.potty)
        case .sleep: Image(Asset.Records.Color.sleep)
        case .heightWeight: Image(Asset.Records.Color.heightWeight)
        case .bath: Image(Asset.Records.Color.bath)
        case .snack: Image(Asset.Records.Color.snack)
        case .health: Image(Asset.Records.Color.clinic)
        case .memo: Image(Asset.Records.Color.memo)
        }
    }
}

#Preview {
    CareEntryGrid { _ in }
        .padding()
}
