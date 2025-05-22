//
//  BabyBirthdayInfo.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/12/25.
//

import SwiftUI

extension View {
    func withBabyInfoCard(babyName: String, birthDate: Date) -> some View {
        self.overlay(
            BabyBirthdayInfoView(babyName: babyName, birthDate: birthDate)
                .padding(.top, 8)
                .padding(.bottom, 12),
            alignment: .top
        )
    }
}

struct BabyBirthdayInfoView: View {
    let babyName: String
    let birthDate: Date
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(babyName) 생일")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(birthDateString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                
                Text(ageString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("태어난지")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(daysSinceBirth)")
                        .font(.custom("Cafe24-Ohsquareair", size: 48))
                    
                    Text("일")
                        .font(.system(size: 24, weight: .medium))
                        .offset(y: 5)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 80)
        .background(.clear)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var birthDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: birthDate)
    }
    
    private var ageString: String {
        let calendar = Calendar.current
        let now = Date()
        
        let totalDays = (calendar.dateComponents([.day], from: calendar.startOfDay(for: birthDate), to: calendar.startOfDay(for: now)).day ?? 0) + 1
        
        let months = totalDays / 30
        let days = totalDays % 30
        
        return "\(months)개월 \(days)일"
    }
    
    private var daysSinceBirth: Int {
        let calendar = Calendar.current
        let now = Date()
        
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: birthDate), to: calendar.startOfDay(for: now)).day ?? 0
        return days + 1
    }
}

#Preview {
    VStack {
        Spacer()
            .frame(height: 100)
        
        BabyBirthdayInfoView(
            babyName: "김죠스",
            birthDate: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 19)) ?? Date()
        )
    }
}
