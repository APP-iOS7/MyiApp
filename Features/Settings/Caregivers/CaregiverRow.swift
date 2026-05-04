import DesignSystem
import Domain
import SwiftUI

struct CaregiverRow: View {
    let caregiver: Caregiver
    let isMain: Bool
    let isSelf: Bool

    var body: some View {
        HStack(spacing: Spacing.m) {
            avatar
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Text(displayName)
                        .font(.body)
                        .foregroundColor(.Semantic.sectionHeading)
                    if isMain {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                    if isSelf {
                        Text("(나)")
                            .font(.caption)
                            .foregroundColor(.Semantic.secondaryText)
                    }
                }
                Text(isMain ? "주 양육자" : "보조 양육자")
                    .font(.caption)
                    .foregroundColor(.Semantic.secondaryText)
            }
            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }

    private var displayName: String {
        guard let name = caregiver.displayName, !name.isEmpty else {
            return "이름 없음"
        }

        return name
    }

    @ViewBuilder
    private var avatar: some View {
        if let url = caregiver.photoURL {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image.resizable().scaledToFill()
                default:
                    placeholderImage
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            placeholderImage
                .frame(width: 40, height: 40)
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.Semantic.secondaryText)
    }
}
