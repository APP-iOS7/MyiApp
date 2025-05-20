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

    @State private var showResultView = false
    @State private var result: EmotionResult?

    var body: some View {
        ZStack {
            switch viewModel.step {
            case .recording, .processing:
                ProcessingStateView(viewModel: viewModel, dismiss: dismiss)
            case .result(let res):
                Color.clear
                    .onAppear {
                        if self.result == nil {
                            self.result = res
                            self.showResultView = true
                        }
                    }
            case .error(let message):
                ErrorStateView(message: message, dismiss: dismiss)
            default:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showResultView) {
            if let result {
                CryAnalysisResultView(
                    viewModel: viewModel,
                    emotionType: result.type,
                    confidence: Float(result.confidence)
                )
            }
        }
        .onChange(of: viewModel.shouldDismissResultView) { shouldDismiss in
            if shouldDismiss {
                showResultView = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

private struct ProcessingStateView: View {
    @ObservedObject var viewModel: VoiceRecordViewModel
    let dismiss: DismissAction
    @State private var dotCount: Int = 0
    private let dotTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("분석 중")
                .font(.system(size: 32, weight: .heavy))
                .padding(.top)

            EqualizerView()
                .padding(.horizontal, 24)
                .frame(height: 140)

            Image("CryAnalysisProcessingShark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            
            Spacer()
            
            Text("아기의 상태를 분석하고 있어요" + String(repeating: ".", count: dotCount))
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            Spacer()
            
            Button(action: {
                viewModel.cancel()
                dismiss()
            }) {
                Text("취소")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("sharkPrimaryColor"))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
            }
            
            Spacer().frame(height: 16)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.cancel()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
        .onReceive(dotTimer) { _ in
            dotCount = (dotCount + 1) % 4
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
            
            Image("CryAnalysisErrorShark")
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
            
            Button(action: {
                dismiss()
            }) {
                Text("닫기")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("sharkPrimaryColor"))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
            }
            
            Spacer().frame(height: 16)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
#Preview {
    let mockViewModel = VoiceRecordViewModel()
    mockViewModel.step = .processing
    return CryAnalysisProcessingView(viewModel: mockViewModel)
}
