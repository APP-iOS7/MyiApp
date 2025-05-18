//
//  CryAnalysisResultView.swift
//  MyiApp
//
//  Created by 조영민 on 5/13/25.
//

import SwiftUI

struct CryAnalysisResultView: View {
    @Environment(\.dismiss) private var dismiss
    
    let emotionType: EmotionType
    let confidence: Float
    
    private var resultImageName: String {
        switch emotionType {
        case .hungry:
            return "sharkHungry"
        case .scared:
            return "sharkScared"
        case .tired:
            return "sharkSleepy"
        case .lonely:
            return "sharkLonely"
        case .burping:
            return "sharkBurping"
        case .bellyPain:
            return "sharkBelly"
        case .coldHot:
            return "sharkTemp"
        case .discomfort:
            return "sharkDiscomfort"
        case .unknown:
            return "sharkUnknown"
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
                Text(emotionType.displayName)
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
    CryAnalysisResultView(emotionType: .lonely, confidence: 0.81)
}
