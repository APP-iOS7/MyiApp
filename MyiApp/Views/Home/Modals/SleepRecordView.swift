//
//  SleepRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct SleepRecordView: View {
    @Binding var record: Record
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
                    Text(record.sleepStart == nil ? "시작 시간 선택" : 
                        record.sleepStart!.formattedKoreanDateString() + " " + 
                        record.sleepStart!.to24HourTimeString()
                    )
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(record.sleepStart == nil ? .gray : .primary)
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
                    Text(record.sleepEnd == nil ? "종료 시간 선택" : 
                        record.sleepEnd!.formattedKoreanDateString() + " " + 
                        record.sleepEnd!.to24HourTimeString()
                    )
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(record.sleepEnd == nil ? .gray : .primary)
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
            UIDatePickerActionSheet(
                isPresented: $isStartPresented,
                selectedDate: Binding(
                    get: { record.sleepStart ?? Date() },
                    set: { record.sleepStart = $0 }
                )
            )
        )
        .background {
            UIDatePickerActionSheet(
                isPresented: $isEndPresented,
                selectedDate: Binding(
                    get: { record.sleepEnd ?? Date() },
                    set: { record.sleepEnd = $0 }
                )
            )
        }
    }
}

//#Preview {
//    SleepRecordView()
//}
