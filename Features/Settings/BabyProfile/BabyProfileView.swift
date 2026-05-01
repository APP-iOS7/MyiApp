import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct BabyProfileView: View {
    @Bindable var store: StoreOf<BabyProfileFeature>

    public init(store: StoreOf<BabyProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            avatar
            infoCard
            Spacer()
        }
        .padding(Spacing.m)
        .labeledContentStyle(RowLabeledContentStyle())
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("아이 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension BabyProfileView {
    var avatar: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.Semantic.secondaryText)
    }

    var infoCard: some View {
        SectionCard(spacing: 0) {
            Button { store.send(.nameRowTapped) } label: {
                LabeledContent {
                    HStack(spacing: Spacing.s) {
                        Text(store.baby.name)
                            .foregroundColor(.Semantic.secondaryText)
                        RowChevron()
                    }
                } label: {
                    Text("이름 / 태명")
                        .foregroundColor(.Semantic.sectionHeading)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())

            Button { store.send(.birthDateRowTapped) } label: {
                LabeledContent {
                    HStack(spacing: Spacing.s) {
                        Text(store.baby.birthDate.formatted(date: .long, time: .omitted))
                            .foregroundColor(.Semantic.secondaryText)
                        RowChevron()
                    }
                } label: {
                    Text("출생일")
                        .foregroundColor(.Semantic.sectionHeading)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())

            LabeledContent {
                Text(store.baby.gender.displayName)
                    .foregroundColor(.Semantic.secondaryText)
            } label: {
                Text("성별")
                    .foregroundColor(.Semantic.sectionHeading)
            }

            LabeledContent {
                Text(store.baby.bloodType.rawValue)
                    .foregroundColor(.Semantic.secondaryText)
            } label: {
                Text("혈액형")
                    .foregroundColor(.Semantic.sectionHeading)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BabyProfileView(
            store: Store(
                initialState: BabyProfileFeature.State(
                    baby: Baby(
                        name: "꼬미",
                        birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date()) ?? Date(),
                        gender: .female,
                        bloodType: .a,
                        mainCaregiverID: "preview"
                    )
                )
            ) {
                BabyProfileFeature()
            }
        )
    }
}
