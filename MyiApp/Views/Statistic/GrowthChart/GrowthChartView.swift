//
//  GrowthChartView.swift
//  MyiApp
//
//  Created by 이민서 on 5/14/25.
//

import SwiftUI

struct GrowthChartView: View {
    
    let baby: Baby
    let records: [Record]
    
    var birthDate: Date {
        baby.birthDate
    }
    var heightweightRecords: [Record] {
        records.filter { $0.title == .heightWeight }
    }
    var heightData: [(date: Date, height: Double)] {
        heightweightRecords.compactMap { record in
            guard let height = record.height else { return nil }
            return (record.createdAt, height)
        }
    }
    var weightData: [(date: Date, weight: Double)] {
        heightweightRecords.compactMap { record in
            guard let weight = record.weight else { return nil }
            return (record.createdAt, weight)
        }
    }
    
    
    @State private var selectedDate = Date()
    @State private var selectedMode = "키"
    let modes = ["키", "몸무게"]
    
    @State private var startDate: Date
    @State private var endDate: Date
    
    init(baby: Baby, records: [Record]) {
        self.baby = baby
        self.records = records
        _startDate = State(initialValue: baby.birthDate)
        _endDate = State(initialValue: Date())
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHeightEntry: HeightEntry? = nil
    @State private var selectedWeightEntry: WeightEntry? = nil
    var body: some View {
        ZStack {
            mainScrollView
        }
        .navigationTitle("성장곡선")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
        }
    }
    var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    toggleMode
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                DateRangeSelectView(startDate: $startDate, endDate: $endDate)
                
                VStack(spacing: 10) {
                    if (selectedMode == "키") {
                        HeightChartView(
                            data: heightData,
                            startDate: startDate,
                            endDate: endDate,
                            selectedEntry: $selectedHeightEntry
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                    } else {
                        WeightChartView(
                            data: weightData,
                            startDate: startDate,
                            endDate: endDate,
                            selectedEntry: $selectedWeightEntry
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                    }
                }
                .frame(minHeight: 300)
                Divider()
                    .padding(.top, {
                        if selectedMode == "키" {
                            return selectedHeightEntry == nil ? 0 : 100
                        } else {
                            return selectedWeightEntry == nil ? 0 : 100
                        }
                    }())
                VStack(spacing: 10) {
                    if (selectedMode == "키") {
                        lastHeightInfoView(
                            data: heightData
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                    } else {
                        lastWeightInfoView(
                            data: weightData
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)

            }
            .padding()
        }
        
    }
    private var toggleMode: some View {
        Picker("모드 선택", selection: $selectedMode) {
            ForEach(modes, id: \.self) { mode in
                Text(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .frame(width: 200, height: 50)
    }
}
func longDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy년 M월 d일"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
}
struct HeightEntry: Identifiable, Equatable {
    let index: Int
    let date: Date
    let height: Double
    var id: String {
            "\(date.timeIntervalSince1970)-\(height)-\(index)"
        }
}
struct WeightEntry: Identifiable, Equatable {
    let index: Int
    let date: Date
    let weight: Double
    var id: String {
            "\(date.timeIntervalSince1970)-\(weight)-\(index)"
        }
}





