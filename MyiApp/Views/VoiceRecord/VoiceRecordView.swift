//
//  VoiceRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI
import AVFAudio

enum CryRoute {
    case processing(id: UUID = UUID())
    case result(emotion: EmotionResult, id: UUID = UUID())
}

extension CryRoute: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .processing:
            hasher.combine("processing")
        case .result(let emotion, let id):
            hasher.combine("result")
            hasher.combine(emotion.type)
            hasher.combine(emotion.confidence)
            hasher.combine(id)
        }
    }
}

extension CryRoute: Equatable {
    static func == (lhs: CryRoute, rhs: CryRoute) -> Bool {
        switch (lhs, rhs) {
        case (.processing, .processing):
            return true
        case (.result(let a, let lhsID), .result(let b, let rhsID)):
            return a.type == b.type && a.confidence == b.confidence && lhsID == rhsID
        default:
            return false
        }
    }
}

struct VoiceRecordView: View {
    @StateObject private var viewModel: VoiceRecordViewModel = .init()
    @State private var navigationPath = NavigationPath()
    @State private var showResultList = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                SafeAreaPaddingView()
                    .frame(height: getTopSafeAreaHeight())
                
                HStack(alignment: .center, spacing: 10) {
                    Text("울음분석")
                        .font(.title)
                        .bold()

                    Spacer()

                    Image(systemName: "list.bullet")
                        .foregroundColor(.primary)
                        .font(.title2)
                        .padding(.leading)
                        .onTapGesture {
                            showResultList.toggle()
                        }
                }
                .padding(.top)

                VStack {
                    Spacer()

                    Image("CryAnalysisProcessingShark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.bottom, 20)

                    Text("시작 버튼을 누른 후 아이의 울음소리를 들려주세요")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.bottom, 20)

                    Text("녹음은 최대 7초 동안 진행됩니다.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 10)

                    Text("가장 뚜렷한 울음소리가 들릴 때 녹음을 시작해 주세요.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 10)

                    Text("정확한 분석을 위해 조용한 환경에서 녹음해 주세요.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 20)

                    Spacer(minLength: 16)
                }
                .frame(width: UIScreen.main.bounds.width - 40)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(12)
                .padding(.top, 16)

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color("customBackgroundColor"))
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    viewModel.resetAnalysisState()
                    viewModel.startAnalysis()
                    navigationPath = NavigationPath()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navigationPath.append(CryRoute.processing())
                    }
                }) {
                    Text("분석 시작")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .frame(height: 50)
                        .background(Color("buttonColor"))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
            }
            .navigationDestination(for: CryRoute.self) { route in
                switch route {
                case .processing(let id):
                    CryAnalysisProcessingView(viewModel: viewModel) { result in
                        navigationPath.removeLast()
                        navigationPath.append(CryRoute.result(emotion: result, id: UUID()))
                    }
                    .id(id)

                case .result(let emotion, _):
                    CryAnalysisResultView(
                        viewModel: viewModel,
                        emotionType: emotion.type,
                        confidence: Float(emotion.confidence),
                        onDismiss: {
                            navigationPath = NavigationPath()
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $showResultList) {
                CryAnalysisResultListView()
                    .environmentObject(viewModel)
            }
            .onAppear {
                AVAudioApplication.requestRecordPermission { granted in
                    if !granted {
                        DispatchQueue.main.async {
                            viewModel.step = .error("마이크 권한이 거부되어 녹음을 시작할 수 없어요.")
                        }
                    }
                }
            }
        }
    }
}
