//
//  CryAnalysisResultView.swift
//  MyiApp
//
//  Created by 조영민 on 5/13/25.
//

import SwiftUI

private enum Constants {
    static let ringStrokeWidth: CGFloat = 12
    static let ringBackgroundOpacity: Double = 0.3
    static let confidenceAnimationDuration: Double = 0.8
    static let iconSize: CGFloat = 140
    static let ringSize: CGFloat = 230
    static let percentageFontSize: CGFloat = 24
    static let titleFontSize: CGFloat = 32
    static let emotionTypeFontSize: CGFloat = 40
    static let tipsFontSize: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let contentSpacing: CGFloat = 24
    static let tipsSpacing: CGFloat = 8
}

// MARK: - ConfidenceRingView
struct ConfidenceRingView: View {
    let confidence: Float
    let imageName: String
    
    private var percentageText: String {
        return "\(Int(confidence * 100))%"
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(Constants.ringBackgroundOpacity),
                    lineWidth: Constants.ringStrokeWidth
                )

            if imageName.contains("Unknown") {
                Circle()
                    .stroke(
                        Color("buttonColor"),
                        style: StrokeStyle(
                            lineWidth: Constants.ringStrokeWidth,
                            lineCap: .round
                        )
                    )
            } else {
                Circle()
                    .trim(from: 0, to: CGFloat(confidence))
                    .stroke(
                        Color("buttonColor"),
                        style: StrokeStyle(
                            lineWidth: Constants.ringStrokeWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeOut(duration: Constants.confidenceAnimationDuration),
                        value: confidence
                    )
            }

            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: Constants.iconSize,
                        height: Constants.iconSize
                    )
                    .accessibilityLabel(getAccessibilityLabel(for: imageName))

                if !imageName.contains("Unknown") {
                    Text(percentageText)
                        .font(.system(size: Constants.percentageFontSize, weight: .bold))
                        .accessibilityLabel("확률 \(percentageText)")
                }
            }
        }
        .frame(width: Constants.ringSize, height: Constants.ringSize)
    }
    
    // 접근성 레이블 생성
    private func getAccessibilityLabel(for imageName: String) -> String {
        let baseType = imageName.replacingOccurrences(of: "shark", with: "")
        return "\(baseType) 상태 이미지"
    }
}

// MARK: - CryAnalysisResultView
struct CryAnalysisResultView: View {
    @ObservedObject var viewModel: VoiceRecordViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    let emotionType: EmotionType
    let confidence: Float
    let onDismiss: () -> Void
    
    // MARK: - Computed Properties
    private var resultImageName: String {
        return emotionType.rawImageName
    }

    private var localizedTips: [String] {
        return tips(for: emotionType)
    }
    
    // MARK: - Methods
    private func tips(for emotion: EmotionType) -> [String] {
        switch emotion {
        case .discomfort:
            return [
                LocalizedStrings.discomfortTip1,
                LocalizedStrings.discomfortTip2,
                LocalizedStrings.discomfortTip3
            ]
        case .hungry:
            return [LocalizedStrings.hungryTip]
        case .tired:
            return [LocalizedStrings.tiredTip]
        case .scared:
            return [LocalizedStrings.scaredTip]
        default:
            return [LocalizedStrings.defaultTip]
        }
    }
    
    // MARK: - View Body
    var body: some View {
        VStack(spacing: Constants.contentSpacing) {
            Text(LocalizedStrings.resultTitle)
                .font(.system(size: Constants.titleFontSize, weight: .heavy))
                .padding(.top)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            ConfidenceRingView(confidence: confidence, imageName: resultImageName)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(emotionType.displayName) 상태, 확률 \(Int(confidence * 100))%")
            
            Spacer()
            
            VStack(spacing: Constants.tipsSpacing) {
                Text(emotionType.displayName)
                    .font(.system(size: Constants.emotionTypeFontSize, weight: .bold))
                    .padding()
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(alignment: .leading, spacing: Constants.tipsSpacing) {
                Text(LocalizedStrings.tipsIntro)
                    .font(.system(size: Constants.tipsFontSize))
                
                ForEach(localizedTips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 4) {
                        Text("•")
                            .font(.system(size: Constants.tipsFontSize))
                        Text(tip)
                            .font(.system(size: Constants.tipsFontSize))
                    }
                }
            }
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityTipsLabel)

            Spacer()

            Button(action: {
                onDismiss()
            }) {
                Text(LocalizedStrings.closeButton)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("buttonColor"))
                    .cornerRadius(Constants.cornerRadius)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            .accessibilityHint(LocalizedStrings.closeButtonHint)

            Spacer(minLength: 20)
        }
        .padding(.top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("[ResultView] 결과 화면 표시됨: \(emotionType.rawValue)")
        }
    }
    
    // 접근성 팁 레이블 생성
    private var accessibilityTipsLabel: String {
        let tipsJoined = localizedTips.joined(separator: ", ")
        return "\(LocalizedStrings.tipsIntro), \(tipsJoined)"
    }
}

// MARK: - Extension EmotionType
extension EmotionType {
    var rawImageName: String {
        switch self {
        case .hungry:
            return "sharkHungry"
        case .scared:
            return "sharkScared"
        case .tired:
            return "sharkTired"
        case .lonely:
            return "sharkLonely"
        case .burping:
            return "sharkBurping"
        case .bellyPain:
            return "sharkBellyPain"
        case .coldHot:
            return "sharkColdHot"
        case .discomfort:
            return "sharkDiscomfort"
        case .unknown:
            return "sharkUnknown"
        }
    }
}

// MARK: - Localized Strings
struct LocalizedStrings {
    // 실제 구현에서는 NSLocalizedString 또는 SwiftUI의 LocalizedStringKey로 대체
    static let resultTitle = "결과"
    static let tipsIntro = "진정하도록 기다려야 합니다. "
    static let closeButton = "닫기"
    static let closeButtonHint = "결과 화면을 닫고 처음으로 돌아갑니다"
    
    // Tips
    static let discomfortTip1 = "잔잔한 백색소음을 틀어주세요."
    static let discomfortTip2 = "아기의 등을 부드럽게 토닥여 주세요."
    static let discomfortTip3 = "안정감을 줄 수 있는 반복적인 소리를 활용해보세요."
    static let hungryTip = "수유를 고려해보세요."
    static let tiredTip = "조용한 환경에서 재워주세요."
    static let scaredTip = "아이를 안아 안심시켜 주세요."
    static let defaultTip = "아기를 관찰하고 추가 반응을 살펴보세요."
}

#Preview {
    let mockViewModel = VoiceRecordViewModel()
    CryAnalysisResultView(viewModel: mockViewModel, emotionType: .unknown, confidence: 0.81, onDismiss: {})
}
