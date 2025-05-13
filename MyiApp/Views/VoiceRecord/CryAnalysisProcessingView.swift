//
//  CryAnalysisProcessingView.swift
//  MyiApp
//
//  Created by 조영민 on 5/12/25.
//

import SwiftUI

struct CryAnalysisProcessingView: View {
    @State private var dotCount: Int = 0
    @State private var showResultView = false
    @Environment(\.dismiss) private var dismiss
    
    private let dotTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 24)

            Text("분석 중")
                .font(.system(size: 24, weight: .bold))
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
                .foregroundColor(.black)
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

            Spacer().frame(height: 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue) // Or your custom color
                }
            }
        }
        .onAppear {
            // No-op, but required for .onReceive to start
        }
        .onReceive(dotTimer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

#Preview {
    CryAnalysisProcessingView()
}
