//
//  CryAnalysisProcessingView.swift
//  MyiApp
//
//  Created by 조영민 on 5/12/25.
//

import SwiftUI

struct CryAnalysisProcessingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VoiceRecordViewModel
    let onComplete: (EmotionResult) -> Void
    @State private var result: EmotionResult?

    var body: some View {
        ZStack {
            switch viewModel.step {
            case .recording, .processing:
                ProcessingStateView(viewModel: viewModel, dismiss: dismiss)
            case .result(let res):
                Color.clear
                    .onAppear {
                        print("[ProcessingView] result onAppear — 새 result 도착: \(res.type) / \(res.confidence)") // ✅ 여기에 쓰는 게 맞음

                        if result?.type != res.type || result?.confidence != res.confidence {
                            self.result = res
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onComplete(res)
                            }
                        }
                    }
            case .error(let message):
                ErrorStateView(message: message, dismiss: dismiss)
            default:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            result = nil
        }
    }
}

private struct ProcessingStateView: View {
    @ObservedObject var viewModel: VoiceRecordViewModel
    let dismiss: DismissAction
    @State private var dotCount: Int = 0
    private let dotTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var progress: Double = 0.0
    @State private var startTime: Date? = nil
    private let totalDuration: Double = 7.0
    private let updateInterval: Double = 0.05
    private let progressTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Text("분석 중")
                    .font(.system(size: 20, weight: .semibold))

                HStack {
                    Button(action: {
                        viewModel.cancel()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            Spacer()
            EqualizerView()
                .padding(.horizontal, 24)
                .frame(height: 140)
            

            Image("CryAnalysisProcessingShark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            
            Text("아기의 상태를 분석하고 있어요" + String(repeating: ".", count: dotCount))
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            Text("소음이 심한 경우 정확도가 \n 떨어질 수 있어요")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal, 24)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .onReceive(dotTimer) { _ in
            dotCount = (dotCount + 1) % 4
        }
        .onAppear {
            startTime = Date()
            
        }
        .onReceive(progressTimer) { _ in
            guard let start = startTime else { return }
            let elapsed = Date().timeIntervalSince(start)
            progress = min(elapsed / totalDuration, 1.0)
        }
    }
}

private struct ErrorStateView: View {
    let message: String
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 24) {
            Text("오류 발생")
                .font(.system(size: 32, weight: .heavy))
                .padding(.top)
            
            Spacer()
            
            Image("sharkUnknown")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .padding()
            
            Text(message)
                .font(.system(size: 20))
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
        }
    }
}

//#Preview {
//    let mockViewModel = VoiceRecordViewModel()
//    mockViewModel.step = .processing
//    CryAnalysisProcessingView(viewModel: mockViewModel, onComplete: { _ in })
//}
