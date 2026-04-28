import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
        UITabBar.appearance().unselectedItemTintColor = .systemGray
    }

    public var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                HomeView(store: store.scope(state: \.home, action: \.home))
            }
            .tabItem { Label("홈", systemImage: "house.fill") }
            .tag(MainTabFeature.Tab.home)

            NavigationStack {
                NoteView(baby: store.selectedBaby)
            }
            .tabItem { Label("육아 수첩", systemImage: "book.fill") }
            .tag(MainTabFeature.Tab.note)

            NavigationStack {
                VoiceView(baby: store.selectedBaby)
            }
            .tabItem { Label("울음 분석", systemImage: "waveform") }
            .tag(MainTabFeature.Tab.voice)

            NavigationStack {
                StatisticView(store: store.scope(state: \.statistic, action: \.statistic))
            }
            .tabItem { Label("기록 분석", systemImage: "chart.bar.fill") }
            .tag(MainTabFeature.Tab.statistic)

            NavigationStack {
                SettingsView(store: store.scope(state: \.settings, action: \.settings))
            }
            .tabItem { Label("더 보기", systemImage: "line.3.horizontal") }
            .tag(MainTabFeature.Tab.settings)
        }
        .tint(Color.Semantic.primaryAction)
    }

}
