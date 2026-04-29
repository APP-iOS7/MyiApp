import DesignSystem
import SwiftUI

struct NoteEventRow: View {
    let title: String
    let description: String
    let date: Date
    let hasImage: Bool
    let hasReminder: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            if hasImage {
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(Color.gray.opacity(Opacity.track))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.Semantic.secondaryText)
                    )
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    if hasReminder {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(.Semantic.primaryAction)
                    }
                    Text(date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundColor(.Semantic.secondaryText)
                        .monospacedDigit()
                }

                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)

                if !description.isEmpty {
                    Text(description)
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
            // 1. 사진 ✓ / 알림 ✗ / 설명 ✓ — 기본 추억
            NoteEventRow(
                title: "처음 뒤집기 성공! 🎉",
                description: "오후 낮잠 후에 갑자기 뒤집어서 깜짝 놀랐다. 이렇게 조금 더 글을 쓰면 길어지겠진ㅇㄹ마ㅣ눌ㄹㄴㅇㄹ나",
                date: Date(),
                hasImage: true,
                hasReminder: false
            )
            Divider()

            // 2. 사진 ✗ / 알림 ✓ / 설명 ✓ — 기본 일정
            NoteEventRow(
                title: "소아과 예약",
                description: "예방접종 + 정기 검진",
                date: Date(),
                hasImage: false,
                hasReminder: true
            )
            Divider()

            // 3. 사진 ✗ / 알림 ✗ / 설명 ✓ — 단순 기록
            NoteEventRow(
                title: "수면 일지",
                description: "8시간 푹 잠. 새벽에 한 번만 깸.",
                date: Date(),
                hasImage: false,
                hasReminder: false
            )
            Divider()

            // 4. 사진 ✓ / 알림 ✓ / 설명 ✓ — 사진 있는 일정
            NoteEventRow(
                title: "100일 사진 예약",
                description: "스튜디오 14시",
                date: Date(),
                hasImage: true,
                hasReminder: true
            )
            Divider()

            // 5. 사진 ✓ / 알림 ✗ / 설명 ✗ — 사진 + 제목
            NoteEventRow(
                title: "낮잠 자는 모습",
                description: "",
                date: Date(),
                hasImage: true,
                hasReminder: false
            )
            Divider()

            // 6. 사진 ✗ / 알림 ✓ / 설명 ✗ — 알림 + 제목
            NoteEventRow(
                title: "분유 시간",
                description: "",
                date: Date(),
                hasImage: false,
                hasReminder: true
            )
            Divider()

            // 7. 사진 ✗ / 알림 ✗ / 설명 ✗ — 제목만
            NoteEventRow(
                title: "오전 산책",
                description: "",
                date: Date(),
                hasImage: false,
                hasReminder: false
            )
            Divider()

            // 8. 사진 ✓ / 알림 ✓ / 설명 ✗ — 사진 + 알림 + 제목
            NoteEventRow(
                title: "돌잔치 D-day",
                description: "",
                date: Date(),
                hasImage: true,
                hasReminder: true
            )
        }
        .padding()
    }
}
