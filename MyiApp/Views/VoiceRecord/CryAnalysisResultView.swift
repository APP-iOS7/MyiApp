//
//  CryAnalysisResultView.swift
//  MyiApp
//
//  Created by 조영민 on 5/13/25.
//

import SwiftUI

struct CryAnalysisResultView: View {
    let emotionLabel: String
    let confidence: Float
    
    // TODO: 각 케이스에 맞는 이미지 에셋 추가 후 코드 수정 예정
    private var resultImageName: String {
        switch emotionLabel {
        case "배고파요":
            return "sharkToddler"
        case "무서워요":
            return "sharkToddler"
        case "졸려요":
            return "sharkToddler"
        case "놀아주세요":
            return "sharkToddler"
        default:
            return "sharkToddler"
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("결과")
                .font(.system(size: 28, weight: .bold))

            Image(resultImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)

            VStack(spacing: 8) {
                Text(emotionLabel)
                    .font(.system(size: 24, weight: .bold))
                Text("(\(Int(confidence * 100))%)")
                    .font(.system(size: 20, weight: .bold))
            }

            Spacer()

            Button(action: {
                // 뒤로 가기 처리
            }) {
                Text("돌아가기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
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
