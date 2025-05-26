//
//  CryAnalysisProcessingView.swift
//  MyiApp
//
//  Created by 조영민 on 5/12/25.
//

import SwiftUI

struct CryAnalysisProcessingView: View {
    @Environment(\.dismiss) private var dismiss // 네비게이션에서 현재 뷰를 닫을 수 있는 Environment
    @ObservedObject var viewModel: VoiceRecordViewModel // 상태와 로직을 포함한 뷰 모델
    @State private var result: EmotionResult? // 현재 표시 중인 결과 캐시
    let onComplete: (EmotionResult) -> Void // 결과 전달 클로저

    var body: some View {
        ZStack {
            switch viewModel.step {
            // .recording, .processing이면 ProccessingStateView 렌더링
            case .recording, .processing:
                ProcessingStateView(viewModel: viewModel, dismiss: dismiss)
            // .result면 onAppear에서 onComplete 호출
            case .result(let res):
                Color.clear
                    .onAppear {
                        print("[ProcessingView] result onAppear — 새 result 도착: \(res.type) / \(res.confidence)")

                        if result?.type != res.type || result?.confidence != res.confidence {
                            self.result = res
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onComplete(res)
                            }
                        }
                    }
            // .error면 ErrorStateView 렌더링
            case .error(let message):
                ErrorStateView(message: message, dismiss: dismiss)
            
            // 나머지는 EmptyView 렌더링
            default:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        // 뷰가 사라지면 내부 결과 초기화
        .onDisappear {
            result = nil
        }
    }
}

private struct ProcessingStateView: View {
    @ObservedObject var viewModel: VoiceRecordViewModel
    let dismiss: DismissAction
    @State private var dotCount: Int = 0
    @State private var dotTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
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
            
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 24)

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
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
    @State private var showPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Text("분석 중")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
            }
            .padding([.top, .horizontal])
            
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
        .alert("마이크 접근 권한이 필요합니다.", isPresented: $showPermissionAlert) {
            Button("설정으로 이동", action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            Button("취소", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("앱에서 울음소리를 분석하려면 마이크 권한이 필요해요.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showPermissionAlert = true
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
        }
        .onAppear {
            showPermissionAlert = true
        }
    }
}

//#Preview {
//    let mockViewModel = VoiceRecordViewModel()
//    mockViewModel.step = .processing
//    CryAnalysisProcessingView(viewModel: mockViewModel, onComplete: { _ in })
//}
