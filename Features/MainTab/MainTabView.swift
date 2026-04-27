import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab) {
            placeholderTab(title: "홈")
                .tabItem { Label("홈", systemImage: "house.fill") }
                .tag(MainTabFeature.Tab.home)

            placeholderTab(title: "육아 수첩")
                .tabItem { Label("육아 수첩", systemImage: "book.fill") }
                .tag(MainTabFeature.Tab.note)

            placeholderTab(title: "울음 분석")
                .tabItem { Label("울음 분석", systemImage: "waveform") }
                .tag(MainTabFeature.Tab.voice)

            placeholderTab(title: "기록 분석")
                .tabItem { Label("기록 분석", systemImage: "chart.bar.fill") }
                .tag(MainTabFeature.Tab.statistic)

            placeholderTab(title: "더 보기")
                .tabItem { Label("더 보기", systemImage: "line.3.horizontal") }
                .tag(MainTabFeature.Tab.settings)
        }
        .tint(Color.Semantic.primaryAction)
    }

    private func placeholderTab(title: String) -> some View {
        NavigationStack {
            VStack {
                Text("\(title) — 준비 중")
                    .font(.Style.sectionTitle)
                    .foregroundColor(.Semantic.sectionHeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.Semantic.screenBackground.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
