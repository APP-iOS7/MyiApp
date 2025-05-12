//
//  FeedingRecordView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-12.
//

import SwiftUI

struct FeedingRecordView: View {
    @State private var selectedType: Int = 0
    @State private var amount: Int = 0
    @State private var showMLPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 15) {
                Button(action: { selectedType = 0 }) {
                    VStack {
                        Image(.normalBreastFeeding)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 0 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("모유 수유")
                            .font(.system(size: 14))
                            .tint(selectedType == 0 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 1 }) {
                    VStack {
                        Image(.normalPumpedMilk)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 1 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("유축 수유")
                            .font(.system(size: 14))
                            .tint(selectedType == 1 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 2 }) {
                    VStack {
                        Image(.normalBreastFeeding)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 2 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("분유")
                            .font(.system(size: 14))
                            .tint(selectedType == 2 ? .primary : .secondary)
                    }
                }
                Button(action: { selectedType = 3 }) {
                    VStack {
                        Image(.normalBreastFeeding)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(7)
                            .background(
                                Circle()
                                    .fill(selectedType == 3 ? Color.sharkPrimary : Color.gray)
                            )
                        Text("이유식")
                            .font(.system(size: 14))
                            .tint(selectedType == 3 ? .primary : .secondary)
                    }
                }
            }
            Button(action: { showMLPicker = true }) {
                Text("\(amount) ml")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.75, green: 0.85, blue: 1.0), lineWidth: 2)
                            .frame(height: 60)
                    )
            }
            .padding(.vertical)
            .background(
                MLPickerActionSheet(
                    isPresented: $showMLPicker,
                    selectedAmount: $amount
                )
            )
        }
        .padding(.vertical)
    }
}

#Preview {
    FeedingRecordView()
}
