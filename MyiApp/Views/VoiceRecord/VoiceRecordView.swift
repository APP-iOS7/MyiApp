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
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                // 헤더
                HStack {
                    Text("울음분석")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }
                .padding([.top, .horizontal])

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
                        VStack(spacing: 8) {
                            ForEach(viewModel.recordResults) { result in
                                VoiceRecordResultCard(result: result)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                // 분석 시작 버튼
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
            }
            .padding(.bottom, 15)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationDestination(for: CryRoute.self) { route in
                switch route {
                case .processing(let id):  // UUID 꺼냄
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
        }
    }
}

private struct VoiceRecordResultCard: View {
    let result: VoiceRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d a h:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    VoiceRecordView()
}
