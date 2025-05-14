//
//  FeedingRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct FeedingRecordView: View {
    @Binding var record: Record
    @State private var showMLPicker = false
    @State private var showRightBreastPicker = false
    @State private var showLeftBreastPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 15) {
                Button(
                    action: {
                        record.title = .breastfeeding
                        record.mlAmount = nil
                    }) {
                    VStack {
                        Image(.normalBreastFeeding)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .breastfeeding ? Color.sharkPrimary : Color.gray)
                            )
                        Text("모유 수유")
                            .font(.system(size: 14))
                            .tint(record.title == .breastfeeding ? .primary : .secondary)
                    }
                }
                Button(
                    action: {
                        record.title = .pumpedMilk
                        record.breastfeedingRightMinutes = nil
                        record.breastfeedingLeftMinutes = nil
                        record.mlAmount = nil
                    }) {
                    VStack {
                        Image(.normalPumpedMilk)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .pumpedMilk ? Color.sharkPrimary : Color.gray)
                            )
                        Text("유축 수유")
                            .font(.system(size: 14))
                            .tint(record.title == .pumpedMilk ? .primary : .secondary)
                    }
                }
                Button(
                    action: {
                        record.title = .formula
                        record.breastfeedingRightMinutes = nil
                        record.breastfeedingLeftMinutes = nil
                        record.mlAmount = nil
                    }) {
                    VStack {
                        Image(.normalPowderedMilk)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .formula ? Color.sharkPrimary : Color.gray)
                            )
                        Text("분유")
                            .font(.system(size: 14))
                            .tint(record.title == .formula ? .primary : .secondary)
                    }
                }
                Button(
                    action: {
                        record.title = .babyFood
                        record.breastfeedingRightMinutes = nil
                        record.breastfeedingLeftMinutes = nil
                        record.mlAmount = nil
                    }) {
                    VStack {
                        Image(.normalBabyMeal)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(record.title == .babyFood ? Color.sharkPrimary : Color.gray)
                            )
                        Text("이유식")
                            .font(.system(size: 14))
                            .tint(record.title == .babyFood ? .primary : .secondary)
                    }
                }
            }
            Group {
                if record.title == .breastfeeding {
                    HStack(spacing: 16) {
                        Button(action: { showLeftBreastPicker = true }) {
                            Text(record.breastfeedingLeftMinutes == nil ? "왼쪽 시간 선택" : "왼쪽 \(record.breastfeedingLeftMinutes!) 분")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(record.breastfeedingLeftMinutes == nil ? .gray : .primary)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                                        .frame(height: 60)
                                )
                        }
                        .background(
                            MinutesPickerActionSheet(isPresented: $showLeftBreastPicker,selectedAmount: $record.breastfeedingLeftMinutes)
                        )
                        Button(action: { showRightBreastPicker = true }) {
                            Text(record.breastfeedingRightMinutes == nil ? "오른쪽 시간 선택" : "오른쪽 \(record.breastfeedingRightMinutes!) 분")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(record.breastfeedingRightMinutes == nil ? .gray : .primary)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                                        .frame(height: 60)
                                )
                        }
                        .background(
                            MinutesPickerActionSheet(isPresented: $showRightBreastPicker,selectedAmount: $record.breastfeedingRightMinutes)
                        )
                    }
                } else {
                    Button(action: { showMLPicker = true }) {
                        Text(record.mlAmount == nil ?
                             (record.title == .babyFood ? "이유식량 선택" : "수유량 선택") :
                                "\(record.mlAmount!) ml")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(record.mlAmount == nil ? .gray : .primary)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                                .frame(height: 60)
                        )
                    }
                    .background(
                        MLPickerActionSheet(isPresented: $showMLPicker,selectedAmount: $record.mlAmount)
                    )
                }
            }
            .frame(height: 60)
        }
        .padding(.vertical)
    }
}

#Preview {
//    FeedingRecordView()
}
