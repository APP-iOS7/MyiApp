import DesignSystem
import Domain
import SwiftUI

struct NoteEventRow: View {
    let note: Note

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            if let firstURL = note.imageURLs.first {
                CachedAsyncImage(url: firstURL) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.Semantic.secondaryText)

                    case .empty:
                        ProgressView()

                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 72, height: 72)
                .background(Color.gray.opacity(Opacity.track))
                .clipShape(RoundedRectangle(cornerRadius: Radius.s))
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                if note.kind == .schedule {
                    HStack(spacing: Spacing.xs) {
                        if note.reminder != nil {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(.Semantic.primaryAction)
                        }
                        Text(note.date, format: .dateTime.hour().minute())
                            .font(.caption)
                            .foregroundColor(.Semantic.secondaryText)
                            .monospacedDigit()
                    }
                }

                Text(note.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)

                if !note.description.isEmpty {
                    Text(note.description)
                        .font(.subheadline)
                        .foregroundColor(.Semantic.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
    }
}
