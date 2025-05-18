//
//  CryAnalysisResultView.swift
//  MyiApp
//
//  Created by 조영민 on 5/13/25.
//

import SwiftUI

struct CryAnalysisResultView: View {
    @Environment(\.dismiss) private var dismiss
    
    let emotionLabel: String
    let confidence: Float
    
    // TODO: 각 케이스에 맞는 이미지 에셋 추가 후 코드 수정 예정
    private var resultImageName: String {
        switch emotionLabel {
        case "배고파요":
            return "sharkChild"
        case "무서워요":
            return "sharkChild"
        case "졸려요":
            return "sharkChild"
        case "놀아주세요":
            return "sharkChild"
        default:
            return "sharkChild"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("결과")
                .font(.system(size: 32, weight: .heavy))
                .padding(.top)
            Spacer()
            
            Image(resultImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            
            Spacer()
            
            VStack(spacing: 8) {
                Text(emotionLabel)
                    .font(.system(size: 40, weight: .bold))
                    .padding()
                
                Text("정확도: \(Int(confidence * 100))%")
                    .font(.system(size: 20, weight: .bold))
            }

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

            Spacer(minLength: 20)
        }
        .padding(.top)
    }
}

#Preview {
    CryAnalysisResultView(emotionLabel: "놀아주세요", confidence: 0.81)
}
