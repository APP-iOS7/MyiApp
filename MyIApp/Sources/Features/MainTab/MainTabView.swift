import ComposableArchitecture
import SwiftUI

public struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabFeature>

    public init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            NavigationStack {
                MainView(store: store.scope(state: \.main, action: \.main))
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }
            .tag(MainTabFeature.State.Tab.home)

            NavigationStack {
                PlaceholderView(title: "육아 수첩")
            }
            .tabItem {
                Label("육아 수첩", systemImage: "book.fill")
            }
            .tag(MainTabFeature.State.Tab.note)

            NavigationStack {
                PlaceholderView(title: "울음 분석")
            }
            .tabItem {
                Label("울음 분석", systemImage: "waveform")
            }
            .tag(MainTabFeature.State.Tab.analysis)

            NavigationStack {
                PlaceholderView(title: "기록 분석")
            }
            .tabItem {
                Label("기록 분석", systemImage: "chart.bar.fill")
            }
            .tag(MainTabFeature.State.Tab.stats)

            NavigationStack {
                PlaceholderView(title: "더 보기")
            }
            .tabItem {
                Label("더 보기", systemImage: "line.3.horizontal")
            }
            .tag(MainTabFeature.State.Tab.more)
        }
        .tint(Color.button)
    }
}

private struct PlaceholderView: View {
    let title: String
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
            Text("준비 중입니다.")
                .foregroundColor(.gray)
        }
    }
}
