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
                timelineSection
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

    private var timelineSection: some View {
        SectionCard(spacing: 0) {
            if store.filteredRecords.isEmpty {
                emptyState
            } else {
                timeline
            }
        }
    }

    private var timeline: some View {
        let records = store.filteredRecords
        return ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
            TimelineRow(
                record: record,
                index: index,
                totalCount: records.count
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.Semantic.secondaryText)
            Text("이 날짜에 기록이 없습니다")
                .foregroundColor(.Semantic.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
}

private func previewBaby() -> Baby {
    Baby(
        id: UUID(),
        name: "꼬미",
        birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
        gender: .female,
        bloodType: .a,
        mainCaregiverID: "user-123"
    )
}

#Preview("기록 있음") {
    NavigationStack {
        HomeView(
            store: Store(
                initialState: HomeFeature.State(
                    baby: previewBaby(),
                    records: CareRecord.mocks
                )
            ) {
                HomeFeature()
            }
        )
    }
}

#Preview("기록 없음") {
    NavigationStack {
        HomeView(
            store: Store(
                initialState: HomeFeature.State(
                    baby: previewBaby(),
                    records: []
                )
            ) {
                HomeFeature()
            }
        )
    }
}
