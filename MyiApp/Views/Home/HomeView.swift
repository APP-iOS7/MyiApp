//
//  HomeView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct HomeView: View {
//    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    babyInfoCard
                    dateSection
                    categoryGrid
                    recordTimeline
                }
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        // 로그아웃 등 액션
                    }) {
                        Image(systemName: "bell")
                            .font(.title2)
                    }
                }
            }
        }
    }
    
    private var babyInfoCard: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "person.fill") // 임시 캐릭터
                .resizable()
                .frame(width: 80, height: 80)
                .background(Circle().fill(Color.blue.opacity(0.1)))
            VStack(alignment: .leading, spacing: 4) {
                Text("김죠스")
                    .font(.title2).bold()
                Text("여아")
                    .font(.subheadline)
                Text("2025.05.07")
                    .font(.subheadline)
                Text("1개월 9일")
                    .font(.subheadline)
                Text("39일")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.gray.opacity(0.1)))
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 2, y: 2)
    }
    
    private var dateSection: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Label("05월 01일 (오늘)", systemImage: "calendar")
                .font(.headline)
            Spacer()
            Button(action: {}) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    private var categoryGrid: some View {
        let items = [
            ("수유/이유식", "drop.fill"),
            ("기저귀", "rectangle.fill"),
            ("배변", "drop.fill"),
            ("수면", "moon.zzz.fill"),
            ("키/몸무게", "arrow.up.and.down"),
            ("목욕", "bathtub.fill"),
            ("간식", "takeoutbag.and.cup.and.straw.fill"),
            ("건강 관리", "list.clipboard")
        ]
        return LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 20) {
            ForEach(items, id: \ .0) { item in
                VStack(spacing: 8) {
                    Image(systemName: item.1)
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                    Text(item.0)
                        .font(.caption)
                }
                .padding(4)
            }
        }
        .padding(.horizontal)
    }
    
    private var recordTimeline: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sampleRecords, id: \.self) { record in
                HStack(alignment: .center, spacing: 16) {
                    Text(record.time)
                        .font(.subheadline)
                        .frame(width: 50, alignment: .trailing)
                    Image(systemName: record.icon)
                        .foregroundColor(record.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.title)
                            .font(.body)
                        if let detail = record.detail {
                            Text(detail)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }
    
    private var sampleRecords: [SampleRecord] {
        [
            .init(time: "18:33", icon: "rectangle.fill", color: .pink, title: "수유", detail: "50ml"),
            .init(time: "18:33", icon: "rectangle.fill", color: .pink, title: "분유", detail: "30ml"),
            .init(time: "18:33", icon: "bathtub.fill", color: .blue, title: "목욕", detail: "1회"),
            .init(time: "18:33", icon: "drop.fill", color: .yellow, title: "소변", detail: "1회"),
            
        ]
    }
    
    struct SampleRecord: Hashable {
        let time: String
        let icon: String
        let color: Color
        let title: String
        let detail: String?
    }
}

#Preview {
    HomeView()
}
