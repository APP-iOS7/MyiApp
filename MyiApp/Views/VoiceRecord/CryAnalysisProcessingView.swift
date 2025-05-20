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
    
    var body: some View {
        ZStack {
            // 각 상태에 따른 뷰를 표시
            switch viewModel.step {
            case .processing, .recording:
                ProcessingStateView(dismiss: dismiss, viewModel: viewModel)
            case .result(let result):
                CryAnalysisResultView(emotionType: result.type, confidence: Float(result.confidence))
            case .error(let message):
                ErrorStateView(message: message, dismiss: dismiss)
            default:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// 처리 중 상태를 표시하는 하위 뷰
private struct ProcessingStateView: View {
    let dismiss: DismissAction
    @ObservedObject var viewModel: VoiceRecordViewModel
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
            .padding(.horizontal)

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
        .onReceive(dotTimer) { _ in
            dotCount = (dotCount + 1) % 4
        }
        .onAppear {
            viewModel.startAnalysis()
        }
    }
}

// 에러 상태를 표시하는 하위 뷰
private struct ErrorStateView: View {
    let message: String
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 24) {
            Text("오류 발생")
                .font(.system(size: 32, weight: .heavy))
                .padding(.top)
            
            Spacer()
            
            Image("CryAnalysisErrorShark") // 에러 상태의 이미지(없다면 기본 이미지 사용)
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
            .padding(.horizontal)
            
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
