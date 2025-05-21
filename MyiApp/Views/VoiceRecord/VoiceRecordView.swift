//
//  VoiceRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct VoiceRecordView: View {
    @StateObject private var viewModel: VoiceRecordViewModel = .init()
    
    var body: some View {
        VStack {
            // 헤더
            HStack {
                Text("울음분석")
                    .font(.system(size: 28, weight: .bold))
                Spacer()
            }
            .padding([.top, .horizontal])

            // 결과 리스트
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.recordResults) { result in
                        VoiceRecordResultCard(result: result)
                    }
                }
                .padding(.top, 8)
            }

            // 분석 시작 버튼
            Button(action: startAnalysis) {
                Text("분석 시작")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("sharkPrimaryColor"))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationDestination(isPresented: .constant(viewModel.step == .recording || viewModel.step == .processing)) {
            CryAnalysisProcessingView(viewModel: viewModel)
        }
    }
    
    private func startAnalysis() {
        viewModel.resetAnalysisState()
        viewModel.startAnalysis()
    }
}

private struct VoiceRecordResultCard: View {
    let result: VoiceRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("cryingShark")
                .resizable()
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text("새로운 분석")
                    .font(.headline)
                    .bold()
                Text(result.firstLabel.displayName)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Text(dateString(from: result.createdAt))
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d a h:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

//#Preview {
//    NavigationStack {
//        VoiceRecordView(selectedBaby: Baby(
//            id: UUID(),
//            name: "Test Baby",
//            birthDate: Date(),
//            birthTime: nil,
//            gender: .male,
//            height: 50.0,
//            weight: 3.5,
//            bloodType: .a
//        ))
//    }
//}
