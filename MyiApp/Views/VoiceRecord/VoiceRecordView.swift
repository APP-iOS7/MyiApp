//
//  VoiceRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI
import AVFAudio

enum CryRoute {
    case processing(id: UUID = UUID())
    case result(emotion: EmotionResult, id: UUID = UUID())
}

extension CryRoute: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .processing:
            hasher.combine("processing")
        case .result(let emotion, let id):
            hasher.combine("result")
            hasher.combine(emotion.type)
            hasher.combine(emotion.confidence)
            hasher.combine(id)
        }
    }
}

extension CryRoute: Equatable {
    static func == (lhs: CryRoute, rhs: CryRoute) -> Bool {
        switch (lhs, rhs) {
        case (.processing, .processing):
            return true
        case (.result(let a, let lhsID), .result(let b, let rhsID)):
            return a.type == b.type && a.confidence == b.confidence && lhsID == rhsID
        default:
            return false
        }
    }
}

struct VoiceRecordView: View {
    @StateObject private var viewModel: VoiceRecordViewModel = .init()
    @State private var navigationPath = NavigationPath()
    
    // 선택 모드 관련 상태
    @State private var isSelectionMode = false
    @State private var selectedRecords: Set<UUID> = []
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                // 헤더
                HStack {
                    Text("울음분석")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    // 선택/취소/삭제 버튼
                    if !viewModel.recordResults.isEmpty {
                        if isSelectionMode {
                            HStack(spacing: 12) {
                                // 삭제 버튼 (선택된 항목이 있을 때만 활성화)
                                Button {
                                    showDeleteAlert = true
                                } label: {
                                    Text("삭제")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .bold()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.85))
                                        .clipShape(Capsule())
                                }
                                .disabled(selectedRecords.isEmpty)
                                
                                // 취소 버튼
                                Button {
                                    exitSelectionMode()
                                } label: {
                                    Text("취소")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .bold()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color("buttonColor"))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            Button {
                                enterSelectionMode()
                            } label: {
                                Text("선택")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("buttonColor"))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding([.top, .horizontal])
                .animation(.easeInOut(duration: 0.2), value: isSelectionMode)
                
                // 결과 리스트
                if viewModel.recordResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("아직 기록된 분석 결과가 없습니다.")
                            .font(.body)
                            .foregroundColor(.gray)
                        Text("하단의 분석 시작 버튼을 눌러 분석을 시작해보세요.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 80)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.recordResults.enumerated()), id: \.element.id) { index, result in
                                let isFirst = index == 0
                                let isLast = index == viewModel.recordResults.count - 1

                                Button {
                                    if isSelectionMode {
                                        toggleSelection(for: result.id)
                                    } else {
                                        // navigate to detail if needed
                                    }
                                } label: {
                                    HStack(alignment: .center, spacing: 12) {
                                        if isSelectionMode {
                                            Image(systemName: selectedRecords.contains(result.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedRecords.contains(result.id) ? .blue : .gray)
                                                .font(.title3)
                                        }

                                        Image(result.firstLabel.rawImageName)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(8)

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
                                    .padding()
                                    .background(
                                        (selectedRecords.contains(result.id) && isSelectionMode
                                         ? Color.blue.opacity(0.1)
                                         : Color(.systemBackground))
                                        .overlay(
                                            isLast ? nil :
                                            Divider()
                                                .padding(.leading, isSelectionMode ? 88 : 52),
                                            alignment: .bottom
                                        )
                                    )
                                    .cornerRadius(
                                        viewModel.recordResults.count == 1 ? 12 : (isFirst ? 12 : isLast ? 12 : 0),
                                        corners: viewModel.recordResults.count == 1 ? .allCorners : (isFirst ? [.topLeft, .topRight] : isLast ? [.bottomLeft, .bottomRight] : [])
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                
                // 분석 시작 버튼 (선택 모드가 아닐 때만 표시)
                if !isSelectionMode {
                    Button(action: {
                        viewModel.resetAnalysisState()
                        viewModel.startAnalysis()
                        navigationPath = NavigationPath()
                        navigationPath.append(CryRoute.processing())
                    }) {
                        Text("분석 시작")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .frame(height: 50)
                            .background(Color("buttonColor"))
                            .cornerRadius(12)
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.bottom, 15)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationDestination(for: CryRoute.self) { route in
                switch route {
                case .processing(let id):
                    CryAnalysisProcessingView(viewModel: viewModel) { result in
                        navigationPath.removeLast()
                        navigationPath.append(CryRoute.result(emotion: result, id: UUID()))
                    }
                    .id(id)
                    
                case .result(let emotion, _):
                    CryAnalysisResultView(
                        viewModel: viewModel,
                        emotionType: emotion.type,
                        confidence: Float(emotion.confidence),
                        onDismiss: {
                            navigationPath = NavigationPath()
                        }
                    )
                }
            }
            .onAppear {
                AVAudioApplication.requestRecordPermission { granted in
                    if !granted {
                        DispatchQueue.main.async {
                            viewModel.step = .error("마이크 권한이 거부되어 녹음을 시작할 수 없어요.")
                        }
                    }
                }
            }
            .alert("선택한 항목을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    deleteSelectedRecords()
                }
            } message: {
                Text("\(selectedRecords.count)개의 분석 결과가 삭제됩니다.")
            }
        }
    }
    
    // MARK: - Selection Mode Functions
    private func enterSelectionMode() {
        isSelectionMode = true
        selectedRecords.removeAll()
    }
    
    private func exitSelectionMode() {
        isSelectionMode = false
        selectedRecords.removeAll()
    }
    
    private func toggleSelection(for recordId: UUID) {
        if selectedRecords.contains(recordId) {
            selectedRecords.remove(recordId)
        } else {
            selectedRecords.insert(recordId)
        }
    }
    
    private func deleteSelectedRecords() {
        viewModel.deleteRecords(with: selectedRecords)
        exitSelectionMode()
    }
}

private struct VoiceRecordResultCard: View {
    let result: VoiceRecord
    let isSelectionMode: Bool
    let isSelected: Bool
    let onSelectionToggle: () -> Void
    @EnvironmentObject private var viewModel: VoiceRecordViewModel
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showingDeleteAlert = false
    
    private let deleteWidth: CGFloat = -70
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 70)
                        .frame(maxHeight: .infinity)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(20)
                }
            }
            .opacity(offset < -10 ? 1 : 0)
            
            HStack(alignment: .top, spacing: 12) {
                if isSelectionMode {
                    VStack {
                        Spacer()
                        Button(action: onSelectionToggle) {
                            Text("선택")
                                .font(.caption)
                                .foregroundColor(isSelected ? .white : .blue)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(isSelected ? Color.blue : Color.gray)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Image(result.firstLabel.rawImageName)
                    .resizable()
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("새로운 분석")
                        .font(.headline)
                        .bold()
                    Text(result.firstLabel.displayName)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Text(dateString(from: result.createdAt))
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                Spacer()
            }
            .padding()
            .background(
                Color(.tertiarySystemBackground)
                    .overlay(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .offset(x: offset)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy. M. d a h:mm:ss"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
}

