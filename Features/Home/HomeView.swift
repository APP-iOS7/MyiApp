import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                BabyInfoCard(baby: store.baby)
                recordEntrySection
            }
            .padding(Spacing.m)
        }
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }

    private var recordEntrySection: some View {
        SectionCard(spacing: Spacing.m) {
            DayNavigator(selectedDate: $store.selectedDate)
            CareEntryGrid { entry in
                // TODO: 카테고리별 입력 화면 진입
                _ = entry
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            store: Store(
                initialState: HomeFeature.State(
                    baby: Baby(
                        id: UUID(),
                        name: "꼬미",
                        birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
                        gender: .female,
                        bloodType: .a,
                        mainCaregiverID: "user-123"
                    )
                )
            ) {
                HomeFeature()
            }
        )
        .navigationTitle("홈")
        .navigationBarTitleDisplayMode(.inline)
    }
}
