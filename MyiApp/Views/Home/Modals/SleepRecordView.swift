//
//  SleepRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct SleepRecordView: View {
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()
    @State var isStartPresented = false
    @State var isEndPresented = false
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {}) {
                VStack {
                    Image(.normalSleep)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(7)
                        .background(
                            Circle()
                                .fill(Color.sharkPrimary)
                        )
                    Text("수면")
                        .font(.system(size: 14))
                        .tint(.primary)
                }
            }
            HStack {
                Text("시작")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(7)
                Button(action: { isStartPresented = true }) {
                    Text(startTime.formattedKoreanDateString() + " " + startTime.to24HourTimeString())
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                                .frame(height: 40)
                        )
                }
            }
            .padding(.bottom, 9)
            HStack {
                Text("종료")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(7)
                Button(action: { isEndPresented = true }) {
                    Text(endTime.formattedKoreanDateString() + " " + endTime.to24HourTimeString())
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                                .frame(height: 40)
                        )
                }
            }
        }
        .background(
            UIDatePickerActionSheet(isPresented: $isStartPresented, selectedDate: $startTime)
        )
        .background {
            UIDatePickerActionSheet(isPresented: $isEndPresented, selectedDate: $endTime)

        }
    }
}

#Preview {
    SleepRecordView()
}
