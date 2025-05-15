

//
//  ContentView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject var caregiverManager = CaregiverManager.shared

    let baby: Baby = {
            var baby = Baby(
                name: "민서",
                birthDate: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))!,
                gender: .female,
                height: 70.0,
                weight: 8.5,
                bloodType: .A
            )
            baby.records = Record.dummyRecords
            return baby
        }()

    var body: some View {
        Group {
            if caregiverManager.selectedBaby != nil {
                TabView {
                    Tab("홈", systemImage: "house.fill") { NavigationStack { HomeView() } }
                    Tab("육아 수첩", systemImage: "book.fill") { NavigationStack { NoteView() } }
                    Tab("울음 분석", systemImage: "waveform") { NavigationStack { VoiceRecordView() } }
                    Tab("통계", systemImage: "chart.bar.fill") { NavigationStack { StatisticView(baby: baby) } }
                    Tab("더 보기", systemImage: "line.3.horizontal") { NavigationStack { SettingsView() } }
                }
            } else {
                ProgressView("케어기버및 아기 정보를 불러오는 중...")
            }
        }
        .task {
            await caregiverManager.loadCaregiverInfo()
            print("불러오기 완료: \(caregiverManager.babies.count)명")
        }
    }
}

#Preview {
    ContentView()
}
