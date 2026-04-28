import DesignSystem
import SwiftUI

enum HomeCareEntry: CaseIterable, Hashable {
    case feeding
    case potty
    case sleep
    case heightWeight
    case bath
    case snack
    case health
    case memo

    var label: String {
        switch self {
        case .feeding: "수유/이유식"
        case .potty: "배변"
        case .sleep: "수면"
        case .heightWeight: "키/몸무게"
        case .bath: "목욕"
        case .snack: "간식"
        case .health: "건강 관리"
        case .memo: "메모"
        }
    }
}

struct CareEntryGrid: View {
    let onSelect: (HomeCareEntry) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.s) {
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
                    RoundedRectangle(cornerRadius: Radius.l)
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
        case .feeding: Image.Records.Colored.meal
        case .potty: Image.Records.Colored.potty
        case .sleep: Image.Records.Colored.sleep
        case .heightWeight: Image.Records.Colored.heightWeight
        case .bath: Image.Records.Colored.bath
        case .snack: Image.Records.Colored.snack
        case .health: Image.Records.Colored.clinic
        case .memo: Image.Records.Colored.memo
        }
    }
}

#Preview {
    CareEntryGrid { _ in }
        .padding()
}
