//
//  AddRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct AddRecordView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var date: Date = Date()
    @State var showActionSheet = false
    
    let category: CareCategory
    
    var body: some View {
        VStack {
            headerView
            datePicker
            content
            buttonView
        }
        .padding(30)
    }
    
    private var headerView: some View {
        HStack {
            Image(uiImage: category.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48)
                .background(Color.red.clipShape(Circle()))
            Text("\(category.name) 기록")
                .font(.system(size: 25, weight: .medium))
            Spacer()
            Button(action: {}) {
                Image(systemName: "trash")
                    .foregroundStyle(.foreground)
                    .font(.system(size: 20))
            }
        }
    }
    
    private var datePicker: some View {
        HStack {
            Button(action: {showActionSheet = true}) {
                HStack {
                    Image(systemName: "calendar")
                    Text(date.formattedKoreanDateString() + " " + date.to24HourTimeString())
                    Image(systemName: "chevron.down")
                }
                .foregroundStyle(.foreground)
            }
            Spacer()
        }
        .background(
            UIDatePickerActionSheet(isPresented: $showActionSheet, selectedDate: $date)
        )
    }
    
    private var content: some View {
        VStack {
            switch category.name {
                case "수유/이유식":
                    FeedingRecordView()
                case "기저귀":
                    DiaperRecordView()
                case "배변":
                    PottyRecordView()
                case "수면":
                    SleepRecordView()
                case "키/몸무게":
                    HeightWeightRecordView()
                case "목욕":
                    BathRecordView()
                case "간식":
                    SnackRecordView()
                case "건강 관리":
                    HealthRecordView()
                default:
                    Text("지원하지 않는 카테고리입니다.")
            }
        }
    }
    
    private var buttonView: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Text("취소")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            Button(action: { print("저장됨") }) {
                Text("저장")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.75, green: 0.85, blue: 1.0))
                    )
            }
        }
    }
}


#Preview {
    AddRecordView(category: .init(name: "수면", image: .colorBabyFood))
}

#Preview {
    SnackRecordView()
}
