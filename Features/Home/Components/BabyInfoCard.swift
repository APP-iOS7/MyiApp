import DesignSystem
import Domain
import SwiftUI

struct BabyInfoCard: View {
    let baby: Baby

    var body: some View {
        SectionCard(spacing: Spacing.m) {
            HStack(alignment: .center, spacing: Spacing.m) {
                profileImage

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(baby.name)
                        .font(.Style.sectionTitle)
                        .foregroundColor(.Semantic.sectionHeading)

                    HStack(alignment: .firstTextBaseline) {
                        Text(baby.developmentalStage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.Semantic.primaryAction)

                        Spacer()

                        Text("태어난지")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.Semantic.secondaryText)
                        Text(daysOldText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.Semantic.primaryAction)
                    }
                }
            }

            Divider()

            HStack(spacing: Spacing.m) {
                infoItem(title: "생년월일", value: birthDateText)
                Spacer()
                infoItem(title: "성별", value: genderText)
                Spacer()
                infoItem(title: "혈액형", value: "\(baby.bloodType.rawValue) 형")
            }
        }
    }

    @ViewBuilder
    private var profileImage: some View {
        if let url = baby.profileImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    ProgressView()
                case .failure:
                    fallbackImage
                @unknown default:
                    fallbackImage
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
        } else {
            fallbackImage
        }
    }

    private var fallbackImage: some View {
        Image(systemName: "figure.child")
            .font(.system(size: 36))
            .frame(width: 70, height: 70)
            .background(Circle().fill(Color.Semantic.screenBackground))
            .foregroundColor(.Semantic.primaryAction)
    }

    private func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundColor(.Semantic.secondaryText)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.Semantic.sectionHeading)
                .lineLimit(1)
        }
    }

    private var birthDateText: String {
        baby.birthDate.formatted(.dateTime.year().month().day().locale(.init(identifier: "ko_KR")))
    }

    private var genderText: String {
        switch baby.gender {
        case .male: "남자"
        case .female: "여자"
        }
    }

    private var daysOldText: String {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: baby.birthDate),
            to: Calendar.current.startOfDay(for: .now)
        ).day ?? 0
        return "\(days + 1)일"
    }
}

#Preview {
    BabyInfoCard(
        baby: Baby(
            id: UUID(),
            name: "꼬미",
            birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
            gender: .female,
            bloodType: .a,
            mainCaregiverID: "user-123"
        )
    )
    .padding()
    .background(Color.Semantic.screenBackground)
}
