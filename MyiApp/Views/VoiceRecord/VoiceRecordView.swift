//
//  VoiceRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct VoiceRecordView: View {
    @State private var isAnalyzing = false
    @StateObject private var viewModel = VoiceRecordViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("울음 분석")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 13)
            
            Spacer(minLength: 8)
            
            Image("cryingShark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .clipShape(Circle())
            
            Spacer()
            
            Text("시작 버튼을 누른 후 아이의 울음소리를 들려주세요")
                .font(.system(size: 20))
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                viewModel.startAnalysis()
                isAnalyzing = true
            }) {
                Text("분석 시작")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("sharkPrimaryColor"))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
        }
        .navigationDestination(isPresented: $isAnalyzing) {
            CryAnalysisProcessingView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack {
        VoiceRecordView()
    }
}
