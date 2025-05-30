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
            VStack {
                // 상단 헤더
                HStack {
                    Text("울음분석")
                        .font(.title)
                        .bold()

                    Spacer()

                    Button(action: {
                        showResultList.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .imageScale(.large)
                    }
                }
                .padding([.top, .horizontal])

                Spacer()

                Image("CryAnalysisProcessingShark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 20)

                Text("시작 버튼을 누른 후 아이의 울음소리를 들려주세요")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                Spacer(minLength: 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    viewModel.resetAnalysisState()
                    viewModel.startAnalysis()
                    navigationPath = NavigationPath()
                    navigationPath.append(CryRoute.processing())
                }) {
                    Text("분석 시작")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .frame(height: 50)
                        .background(Color("buttonColor"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
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
