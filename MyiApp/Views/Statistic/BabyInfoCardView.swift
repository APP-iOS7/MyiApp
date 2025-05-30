//
//  BabyInfoCardView.swift
//  MyiApp
//
//  Created by 이민서 on 5/30/25.
//

import SwiftUI

struct BabyInfoCardView: View {
    let baby: Baby
    let records: [Record]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("👶 아기 정보")
                .font(.title2)
                .bold()
            Text("이름: \(baby.name)")
            Text("성별: \(baby.gender == .female ? "여자" : "남자")")
            Text("생년월일: \(formattedDate(baby.birthDate))")
            Text("만 나이: \(getFullAge(from: baby.birthDate))세")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }

    private func getFullAge(from birthDate: Date) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let birth = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let today = calendar.dateComponents([.year, .month, .day], from: now)

        var age = (today.year ?? 0) - (birth.year ?? 0)
        if (today.month ?? 0) < (birth.month ?? 0) ||
           ((today.month ?? 0) == (birth.month ?? 0) && (today.day ?? 0) < (birth.day ?? 0)) {
            age -= 1
        }
        return age
    }
}
