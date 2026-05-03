import DesignSystem
import Domain
import SwiftUI

struct CryRecordRow: View {
    let record: CryAnalysisRecord

    var body: some View {
        let primary = record.aggregatedScores.first?.emotion ?? .unknown
        HStack(spacing: Spacing.m) {
            Image(primary.iconAsset)
                .resizable()
                .scaledToFit()
                .frame(width: IconSize.xl, height: IconSize.xl)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(primary.displayName)
                    .font(.headline)
                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color.Semantic.secondaryText)
            }

            Spacer()
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.m)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
    }
}
