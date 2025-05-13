//
//  FeedDetailView.swift
//  MyiApp
//
//  Created by 이민서 on 5/13/25.
//

import SwiftUI

struct FoodDetailView: View {
    
    let records = Record.mockTestRecords
    
    @State private var selectedDate = Date()
    @State private var selectedMode = "일"
    @State private var showCalendar = false
    let modes = ["일", "주", "월"]
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if selectedMode == "일" {
            formatter.dateFormat = "MM월 dd일"
            return formatter.string(from: selectedDate)
        } else if selectedMode == "주" {
            let calendar = Calendar(identifier: .gregorian)
            var mondayStartCalendar = calendar
            mondayStartCalendar.firstWeekday = 2
            
            let startOfWeek = mondayStartCalendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            let endOfWeek = mondayStartCalendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM월 dd일"
            formatter.locale = Locale(identifier: "ko_KR")
            
            let startString = formatter.string(from: startOfWeek)
            let endString = formatter.string(from: endOfWeek)
            
            return "\(startString) ~ \(endString)"
            
        } else {
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        ZStack {
            mainScrollView
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    if let currentIndex = modes.firstIndex(of: selectedMode) {
                        if horizontalAmount < -50 {
                            let nextIndex = (currentIndex + 1) % modes.count
                            selectedMode = modes[nextIndex]
                        } else if horizontalAmount > 50 {
                            let prevIndex = (currentIndex - 1 + modes.count) % modes.count
                            selectedMode = modes[prevIndex]
                        }
                    }
                }
        )
        .navigationTitle("분유/수유/이유식 통계")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    toggleMode
                    Spacer()
                    dateMove
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                if (selectedMode == "일") {
                    DailyFeedChartView(
                        weekDates: generateWeekDates(from: selectedDate),
                        records: records
                    )
                    Divider()
                    DailyFeedListView(records: records,  selectedDate: selectedDate)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                
                
            }
            .padding()
        }
        
    }
    private var toggleMode: some View {
        HStack(spacing: 4) {
            ForEach(modes, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                }) {
                    Text(mode)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedMode == mode ? Color("sharkPrimaryColor") : Color.gray)
                        .frame(maxWidth: 90, minHeight: 32)
                        .background(
                            ZStack {
                                if selectedMode == mode {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                        )
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(width: 200, height: 50)
    }
    private var dateMove: some View {
        Group {
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: selectedMode == "일" ? -1 : -7, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showCalendar.toggle()
                    }
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                }
                
                Text(formattedDateString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: selectedMode == "일" ? 1 : 7, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
            if showCalendar {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .transition(.opacity)
                .tint(Color("sharkPrimaryColor"))
            }
        }
        
    }
    func generateWeekDates(from selectedDate: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 월요일 시작
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
}

struct DailyFeedChartView: View {
    let weekDates: [Date]
    let records: [Record]
    
    enum FeedingType: String, CaseIterable {
        case formula = "분유"
        case pumpedMilk = "유축 수유"
        case breastfeeding = "모유 수유"
        case babyFood = "이유식"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(FeedingType.allCases, id: \.self) { type in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(uiImage: iconImage(for: type))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text(type.rawValue)
                            .font(.headline)
                    }
                    GeometryReader { geometry in
                        let totalWidth = geometry.size.width - 60 //막대 사이 너비가 10인것을 고려
                        let barWidth = totalWidth / CGFloat(weekDates.count)
                        
                        // 날짜별로 값 구해서
                        let values = weekDates.map { date in
                            amountFor(type, on: date)
                        }
                        
                        // 최대값 구하기
                        let maxAmount = values.max() ?? 1 // 0 방지
                        let avgAmount = Double(values.reduce(0, +)) / Double(values.count)
                        let avgY = CGFloat(avgAmount) / CGFloat(maxAmount) * 100
                        
                        ZStack(alignment: .topLeading) {
                            
                            Rectangle()
                                .fill(Color.red.opacity(0.4))
                                .frame(width: totalWidth + 60, height: 1)
                                .offset(y: 100 - avgY)
                                .overlay(
                                    Text("평균 \(Int(avgAmount))\(type == .breastfeeding ? "분" : "ml")")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                        .offset(y: -10),
                                    alignment: .topTrailing
                                )
                            HStack(alignment: .bottom, spacing: 10) {
                                ForEach(Array(zip(weekDates, values)), id: \.0) { date, value in
                                    VStack {
                                        Text("\(value)\(type == .breastfeeding ? "분" : "ml")")
                                            .font(.caption2)
                                            .foregroundColor(.black)
                                            .frame(height: 12)
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(
                                                width: barWidth,
                                                height: CGFloat(value) / CGFloat(maxAmount) * 100
                                            )
                                            .cornerRadius(4)
                                        Text(shortDateString(for: date))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        
                    }
                    .frame(height: 120)

                }
            }
        }
        .padding()
    }
    
    func iconImage(for type: FeedingType) -> UIImage {
        switch type {
        case .formula: return UIImage(named: "nornalFomual") ?? UIImage()
        case .pumpedMilk: return UIImage(named: "normalPumpedMilk") ?? UIImage()
        case .breastfeeding: return UIImage(named: "normalBreastFeeding") ?? UIImage()
        case .babyFood: return UIImage(named: "normalBabyMeal") ?? UIImage()
        }
    }
    
    func titleCategory(of record: Record) -> FeedingType? {
        switch record.title {
        case .formula: return .formula
        case .pumpedMilk: return .pumpedMilk
        case .breastfeeding: return .breastfeeding
        case .babyFood: return .babyFood
        default: return nil
        }
    }
    
    func amountFor(_ type: FeedingType, on date: Date) -> Int {
        let calendar = Calendar.current
        let recordsForDate = records.filter {
            calendar.isDate($0.createdAt, inSameDayAs: date) &&
            titleCategory(of: $0) == type
        }
        
        if type == .breastfeeding {
            return recordsForDate.reduce(0) { total, record in
                total + (record.breastfeedingLeftMinutes ?? 0) + (record.breastfeedingRightMinutes ?? 0)
            }
        } else {
            return recordsForDate
                .compactMap { $0.mlAmount }
                .reduce(0, +)
        }
    }

    
    func shortDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
struct DailyFeedListView: View {
    
    let records: [Record]
    let selectedDate: Date
    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
    
    
    var body: some View {
        
        DetailStatisticCardView(
            title: "일별 통계",
            image: .colorMeal,
            color: Color("food"),
            count: combinedFeedCount(in: records, on: selectedDate),
            lastcount: combinedFeedCount(in: records, on: yesterday),
            amount: totalMlAmount(in: records, on: selectedDate),
            lastamount: totalMlAmount(in: records, on: yesterday),
            time: totalBreastfeedingMinutes(in: records, on: selectedDate),
            lasttime: totalBreastfeedingMinutes(in: records, on: yesterday),
            mode : "daily",
            selectedDate : selectedDate
        )
        .padding(.horizontal)
    }
    // ml 총계
    func totalMlAmount(in records: [Record], on date: Date) -> Int {
        let calendar = Calendar.current
        return records
            .filter {
                [.formula, .babyFood, .pumpedMilk].contains($0.title) &&
                calendar.isDate($0.createdAt, inSameDayAs: date)
            }
            .compactMap { $0.mlAmount }
            .reduce(0, +)
    }
    // 모유 수유 시간 총계
    func totalBreastfeedingMinutes(in records: [Record], on date: Date) -> Int {
        let calendar = Calendar.current
        return records
            .filter {
                $0.title == .breastfeeding &&
                calendar.isDate($0.createdAt, inSameDayAs: date)
            }
            .reduce(0) { total, record in
                let left = record.breastfeedingLeftMinutes ?? 0
                let right = record.breastfeedingRightMinutes ?? 0
                return total + left + right
            }
    }
    // 밥먹은 횟수 따로 셀리기
    func combinedFeedCount(in records: [Record], on date: Date) -> Int {
        let calendar = Calendar.current
        return records.filter {
            [.formula, .pumpedMilk, .breastfeeding, .babyFood].contains($0.title) &&
            calendar.isDate($0.createdAt, inSameDayAs: date)
        }.count
    }
    
}
