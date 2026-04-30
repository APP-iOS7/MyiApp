import DesignSystem
import Domain
import SwiftUI

struct NoteEventRow: View {
    let note: Note

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            if let firstURL = note.imageURLs.first {
                AsyncImage(url: firstURL) { phase in
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

#Preview {
    ScrollView {
        VStack(spacing: Spacing.m) {
            // 일지 — 사진 + 설명
            NoteEventRow(
                note: Note(
                    kind: .diary,
                    title: "처음 뒤집기 성공! 🎉",
                    description: "오후 낮잠 후에 갑자기 뒤집어서 깜짝 놀랐다.",
                    date: Date(),
                    imageURLs: [URL(string: "https://example.com/photo.jpg")].compactMap { $0 }
                )
            )
            Divider()

            // 일지 — 제목만
            NoteEventRow(
                note: Note(kind: .diary, title: "오전 산책", date: Date())
            )
            Divider()

            // 일정 — 알림 없음
            NoteEventRow(
                note: Note(
                    kind: .schedule,
                    title: "조부모님 방문",
                    description: "오후에 오신다고 함",
                    date: Date()
                )
            )
            Divider()

            // 일정 — 알림 있음
            NoteEventRow(
                note: Note(
                    kind: .schedule,
                    title: "소아과 예약",
                    description: "예방접종 + 정기 검진",
                    date: Date(),
                    reminder: Reminder(scheduledAt: Date())
                )
            )
            Divider()

            // 일정 — 사진 + 알림
            NoteEventRow(
                note: Note(
                    kind: .schedule,
                    title: "100일 사진 예약",
                    description: "스튜디오 14시",
                    date: Date(),
                    imageURLs: [URL(string: "https://example.com/photo.jpg")].compactMap { $0 },
                    reminder: Reminder(scheduledAt: Date())
                )
            )
        }
        .padding()
    }
}
