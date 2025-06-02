//
//  CryAnalysisResultListView.swift
//  MyiApp
//
//  Created by 조영민 on 5/30/25.
//

import SwiftUI

struct CryAnalysisResultListView: View {
    @EnvironmentObject var viewModel: VoiceRecordViewModel
    @State private var isSelectionMode: Bool = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                if viewModel.recordResults.isEmpty {
                    EmptyStateView()
                } else {
                    Section {
                        ForEach(viewModel.recordResults, id: \.id) { result in
                            AnalysisResultRow(
                                result: result,
                                viewModel: viewModel,
                                isSelectionMode: isSelectionMode,
                                isSelected: selectedItems.contains(result.id),
                                onTap: {
                                    if selectedItems.contains(result.id) {
                                        selectedItems.remove(result.id)
                                    } else {
                                        selectedItems.insert(result.id)
                                    }
                                }
                            )
                                .background {
                                    Color(UIColor.tertiarySystemBackground)
                                }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .contentMargins(.top, 10)
            .navigationTitle("분석 결과")
            .background(Color.customBackground)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelectionMode {
                    HStack {
                        Button("삭제", role: .destructive) {
                            showDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .alert("선택한 항목을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                            Button("삭제", role: .destructive) {
                                for id in selectedItems {
                                    viewModel.deleteRecord(with: id)
                                }
                                selectedItems.removeAll()
                                isSelectionMode = false
                            }
                            Button("취소", role: .cancel) {}
                        }
                        
                        Button("취소") {
                            selectedItems.removeAll()
                            isSelectionMode = false
                        }
                        .foregroundColor(.primary)
                    }
                } else {
                    Button("선택") {
                        if viewModel.recordResults.isEmpty {
                            showDeleteAlert = true
                        } else {
                            isSelectionMode = true
                        }
                    }
                    .foregroundColor(.primary)
                    .alert("현재 기록된 분석이 없습니다", isPresented: $showDeleteAlert) {
                        Button("확인", role: .cancel) {}
                    }
                }
            }
        }
    }
}

// 별도 컴포넌트로 분리하여 컴파일 최적화
private struct AnalysisResultRow: View {
    let result: VoiceRecord
    let viewModel: VoiceRecordViewModel
    let isSelectionMode: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

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
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .padding(.leading, 16)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.25), value: isSelectionMode)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !isSelectionMode {
                Button("삭제", systemImage: "trash", role: .destructive) {
                    viewModel.deleteRecord(with: result.id)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .onTapGesture {
            if isSelectionMode {
                onTap()
            }
        }
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
