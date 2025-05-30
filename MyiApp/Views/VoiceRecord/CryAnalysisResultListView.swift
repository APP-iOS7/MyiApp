//
//  CryAnalysisResultListView.swift
//  MyiApp
//
//  Created by 조영민 on 5/30/25.
//

import SwiftUI

struct CryAnalysisResultListView: View {
    @EnvironmentObject var viewModel: VoiceRecordViewModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.recordResults.isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("아직 기록된 분석 결과가 없습니다.")
                                .font(.body)
                                .foregroundColor(.gray)
                            Text("분석을 완료하면 결과가 이곳에 표시됩니다.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.7)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.recordResults, id: \.id) { result in
                        HStack(spacing: 12) {
                            Image(result.firstLabel.rawImageName)
                                .resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("새로운 분석")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(result.firstLabel.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(dateString(from: result.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let record = viewModel.recordResults[index]
                            viewModel.deleteRecord(with: record.id)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("분석 결과")
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy. M. d a h:mm:ss"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
}
