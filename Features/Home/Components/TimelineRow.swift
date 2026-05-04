import DesignSystem
import Domain
import Shared
import SwiftUI

struct TimelineRow: View {
    let record: CareRecord
    let index: Int
    let totalCount: Int

    private var showTopLine: Bool { totalCount > 1 && index != 0 }
    private var showBottomLine: Bool { totalCount > 1 && index != totalCount - 1 }

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.m) {
            Text(record.createdAt.hourMinute24h)
                .font(.subheadline.monospacedDigit())

            TimelineTrack(
                tintColor: record.event.category.tintColor,
                showTopLine: showTopLine,
                showBottomLine: showBottomLine
            )

            HStack(spacing: Spacing.m) {
                record.event.icon
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, Spacing.s)

                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text(record.event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.Semantic.sectionHeading)
                    Text(record.subtitleText)
                        .font(.caption2)
                        .foregroundColor(.Semantic.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.Semantic.secondaryText)
        }
        .frame(height: RowHeight.timeline)
        .contentShape(Rectangle())
    }
}
