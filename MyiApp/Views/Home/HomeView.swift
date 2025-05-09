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
                babyInfoCard
                calenderView
                girdItemView
                recordView
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("bell", systemImage: "bell", action: {
                        AuthService.shared.signOut()
                    })
                }
            }
        }
    }
    
    private var babyInfoCard: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
            VStack(alignment: .leading) {
                Text("우리 아기 이름:")
                    .font(.headline)
                Text("2025년 5월 8일")
                    .font(.caption)
                Text("우리 아기 이름:")
                    .font(.headline)
                Text("2025년 5월 8일")
                    .font(.caption)
                Text("우리 아기 이름:")
                    .font(.headline)
                Text("2025년 5월 8일")
                    .font(.caption)
            }
        }
    }
    private var calenderView: some View {
        EmptyView()
    }
    private var girdItemView: some View {
        EmptyView()
    }
    private var recordView: some View {
        EmptyView()
    }
}

#Preview {
    HomeView()
}
