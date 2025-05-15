//
//  ContentView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("홈", systemImage: "house.fill") { NavigationStack { HomeView() } }
            Tab("육아 수첩", systemImage: "book.fill") { NavigationStack { NoteView() } }
            Tab("울음 분석", systemImage: "waveform") { NavigationStack { VoiceRecordView() } }
            Tab("통계", systemImage: "chart.bar.fill") { NavigationStack { StatisticView() } }
            Tab("더 보기", systemImage: "line.3.horizontal") { NavigationStack { SettingsView() } }
        }
    }
}

#Preview {
    ContentView()
}
