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
            
            // Refector to Tab
            
            NavigationStack { HomeView() }
            .tabItem { Label("홈", systemImage: "house.fill") }
            
            NavigationStack { NoteView() }
            .tabItem { Label("육아 수첩", systemImage: "book.fill") }
            
            NavigationStack { VoiceRecordView() }
            .tabItem { Label("울음 분석", systemImage: "waveform") }
            
            NavigationStack { StatisticView() }
            .tabItem { Label("통계", systemImage: "chart.bar.fill") }
            
            NavigationStack { SettingView() }
            .tabItem { Label("더 보기", systemImage: "") }
        }
    }
}

#Preview {
    ContentView()
}
