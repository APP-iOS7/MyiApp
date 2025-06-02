//
//  CryAnalysisResultListView.swift
//  MyiApp
//
//  Created by 조영민 on 5/30/25.
//

import SwiftUI

struct CryAnalysisResultListView: View {
    @EnvironmentObject var viewModel: VoiceRecordViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.recordResults.isEmpty {
                    EmptyStateView()
                } else {
                    ForEach(viewModel.recordResults, id: \.id) { result in
                        AnalysisResultRow(result: result, viewModel: viewModel)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("분석 결과")
        }
    }
}

// 별도 컴포넌트로 분리하여 컴파일 최적화
private struct AnalysisResultRow: View {
    let result: VoiceRecord
    let viewModel: VoiceRecordViewModel

    var body: some View {
        // HStack 전체를 하나의 View로 감싸고, modifier를 HStack 위에 적용
        // Image의 frame/clipShape는 Image에만 적용
        VStack { // workaround: outer View for modifier application
            HStack(spacing: 12) {
                Image(result.firstLabel.rawImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text("새로운 분석")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(result.firstLabel.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(dateString(from: result.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
        }
        .padding(.leading, 16)
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("삭제", systemImage: "trash", role: .destructive) {
                viewModel.deleteRecord(with: result.id)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}


private func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy. M. d a h:mm:ss"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
}

// 빈 상태 뷰 별도 컴포넌트로 분리
private struct EmptyStateView: View {
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                Spacer()
                ContentUnavailableView(
                    "분석 결과가 없습니다",
                    systemImage: "magnifyingglass",
                    description: Text("분석을 완료하면 결과가 이곳에 표시됩니다.")
                )
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.65)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
