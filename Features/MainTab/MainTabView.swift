import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                HomeView(store: store.scope(state: \.home, action: \.home))
            }
            .tabItem { Label("홈", systemImage: "house.fill") }
            .tag(MainTabFeature.Tab.home)

            NavigationStack {
                NoteView(store: store.scope(state: \.note, action: \.note))
            }
            .tabItem { Label("육아 수첩", systemImage: "book.fill") }
            .tag(MainTabFeature.Tab.note)

            CryAnalysisHomeView(store: store.scope(state: \.cryAnalysis, action: \.cryAnalysis))
                .tabItem { Label("울음 분석", systemImage: "waveform") }
                .tag(MainTabFeature.Tab.cryAnalysis)

            NavigationStack {
                StatisticView(store: store.scope(state: \.statistic, action: \.statistic))
            }
            .tabItem { Label("기록 분석", systemImage: "chart.bar.fill") }
            .tag(MainTabFeature.Tab.statistic)

            SettingsView(store: store.scope(state: \.settings, action: \.settings))
                .tabItem { Label("더 보기", systemImage: "line.3.horizontal") }
                .tag(MainTabFeature.Tab.settings)
        }
        .task { await store.send(.task).finish() }
    }
}

#if DEBUG
    #Preview {
        if let state = MainTabFeature.State(
            session: Session(
                uid: "preview",
                providerIDs: []
            ),
            caregiver: Caregiver(id: "preview", createdAt: .now),
            babies: [
                Baby(
                    name: "아기",
                    birthDate: Calendar.current.date(byAdding: .month, value: -3, to: .now) ?? .now,
                    gender: .male,
                    bloodType: .a,
                    mainCaregiverID: "preview"
                ),
            ]
        ) {
            MainTabView(
                store: Store(initialState: state) {
                    MainTabFeature()
                }
            )
        }
    }
#endif
