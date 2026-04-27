import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    let store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                babyInfoCard
            }
            .padding(Spacing.m)
        }
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("홈")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var babyInfoCard: some View {
        SectionCard(spacing: Spacing.m) {
            HStack(alignment: .center, spacing: Spacing.m) {
                Image(systemName: "figure.child")
                    .font(.system(size: 40))
                    .frame(width: 70, height: 70)
                    .background(Circle().fill(Color.Semantic.screenBackground))
                    .foregroundColor(.Semantic.primaryAction)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(store.baby.name)
                        .font(.Style.sectionTitle)
                        .foregroundColor(.Semantic.sectionHeading)

                    Text(daysOldText)
                        .font(.body)
                        .foregroundColor(.Semantic.primaryAction)
                        .fontWeight(.semibold)
                }

                Spacer()
            }

            Divider()

            HStack(spacing: Spacing.m) {
                infoItem(title: "생년월일", value: birthDateText)
                Spacer()
                infoItem(title: "성별", value: genderText)
                Spacer()
                infoItem(title: "혈액형", value: "\(store.baby.bloodType.rawValue) 형")
            }
        }
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
        store.baby.birthDate.formatted(.dateTime.year().month().day().locale(.init(identifier: "ko_KR")))
    }

    private var genderText: String {
        switch store.baby.gender {
        case .male: "남자"
        case .female: "여자"
        }
    }

    private var daysOldText: String {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: store.baby.birthDate),
            to: Calendar.current.startOfDay(for: .now)
        ).day ?? 0
        return "태어난지 \(days)일"
    }
}
