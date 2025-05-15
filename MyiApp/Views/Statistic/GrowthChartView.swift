//
//  GrowthChartView.swift
//  MyiApp
//
//  Created by 이민서 on 5/14/25.
//

import SwiftUI

struct GrowthChartView: View {
    
    let baby: Baby
    
    var birthDate: Date {
        baby.birthDate
    }
    
    var records: [Record] {
        baby.records
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
    @State private var showCalendar = false
    let modes = ["키", "몸무게"]
    
    @State private var startDate: Date
    @State private var endDate: Date
    
    init(baby: Baby) {
        self.baby = baby
        _startDate = State(initialValue: baby.birthDate)
        _endDate = State(initialValue: Date())
    }
    
    var body: some View {
        ZStack {
            mainScrollView
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    if horizontalAmount < -50 && selectedMode == "키" {
                        selectedMode = "몸무게"
                    } else if horizontalAmount > 50 && selectedMode == "몸무게" {
                        selectedMode = "키"
                    }
                }
        )
        .navigationTitle("성장곡선")
        .navigationBarTitleDisplayMode(.inline)
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
                            endDate: endDate
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                    } else {
                        WeightChartView(
                            data: weightData,
                            startDate: startDate,
                            endDate: endDate
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                    }
                }
                .frame(minHeight: 300)
                
                
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
}
struct HeightChartView: View {
    let data: [(date: Date, height: Double)]
    let startDate: Date
    let endDate: Date
    
    @State private var selectedEntry: (date: Date, height: Double)? = nil

    var body: some View {
        GeometryReader { geometry in
            let filteredData = data.filter { $0.date >= startDate && $0.date <= endDate }
            let sortedData = filteredData.sorted { $0.date < $1.date }

            if let lastDate = sortedData.last?.date,
               let minHeight = sortedData.map({ $0.height }).min(),
               let maxHeight = sortedData.map({ $0.height }).max(),
               maxHeight > minHeight {

                let dateRangeInterval = endDate.timeIntervalSince(startDate)
                let intervalStep = dateRangeInterval / 9.0
                let desiredDates: [Date] = (0..<10).map {
                    startDate.addingTimeInterval(Double($0) * intervalStep)
                }

                let cappedData: [(date: Date, height: Double)] = desiredDates.compactMap { targetDate in
                    sortedData.min(by: {
                        //절댓값
                        abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
                    })
                }

                let firstDate = startDate
                let dateRange = endDate.timeIntervalSince(firstDate)
                let heightRange = maxHeight - minHeight
                let oneThirdDate = firstDate.addingTimeInterval(dateRange / 3)
                let twoThirdDate = firstDate.addingTimeInterval(dateRange * 2 / 3)
                let roundedMin = floor(minHeight)
                let roundedMax = ceil(maxHeight)

                VStack(spacing: 8) {
                    HStack(alignment: .top) {
                        VStack {
                            Text("\(Int(roundedMax))")
                            Spacer()
                            Text("\(Int(roundedMax - heightRange * 1/3))")
                            Spacer()
                            Text("\(Int(roundedMax - heightRange * 2/3))")
                            Spacer()
                            Text("\(Int(roundedMin))")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 30)
                        // 세로축 기준선
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1)

                        ZStack(alignment: .topTrailing) {
                            GeometryReader { geo in
                                let width = geo.size.width
                                let height = geo.size.height

                                ZStack {
                                    // 전체 흐릿한 선
                                    Path { path in
                                        for (index, entry) in sortedData.enumerated() {
                                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                            let y = height - ((CGFloat(entry.height - minHeight) / CGFloat(heightRange)) * height)
                                            index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                    .stroke(Color("sharkPrimaryColor").opacity(0.3), lineWidth: 1)

                                    // 강조된 선
                                    Path { path in
                                        for (index, entry) in cappedData.enumerated() {
                                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                            let y = height - ((CGFloat(entry.height - minHeight) / CGFloat(heightRange)) * height)
                                            index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                    .stroke(Color("sharkPrimaryColor"), lineWidth: 2)

                                    // 강조된 점
                                    ForEach(cappedData, id: \.date) { entry in
                                        let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                        let y = height - ((CGFloat(entry.height - minHeight) / CGFloat(heightRange)) * height)
                                        Circle()
                                            .fill(selectedEntry?.date == entry.date ? Color("food") : Color("sharkPrimaryColor"))
                                            .frame(width: 10, height: 10)
                                            .position(x: x, y: y)
                                            .onTapGesture {
                                                if selectedEntry?.date == entry.date {
                                                    selectedEntry = nil
                                                } else {
                                                    selectedEntry = entry
                                                }
                                            }
                                    }
                                    ForEach(cappedData, id: \.date) { entry in
                                        if let entry = selectedEntry {
                                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                            let y = height - ((CGFloat(entry.height - minHeight) / CGFloat(heightRange)) * height)
                                            let yOffset: CGFloat = y > height / 2 ? -50 : 50
                                            
                                            let toStart = abs(entry.date.timeIntervalSince(startDate))
                                            let toEnd = abs(entry.date.timeIntervalSince(endDate))
                                            let xOffset: CGFloat = toStart < toEnd ? 30 : -30
                                            VStack(alignment: .leading) {
                                                Text("날짜 : \(longDate(entry.date))")
                                                    .font(.footnote)
                                                Text("키 : \(String(format: "%.1f", entry.height))cm")
                                                    .font(.footnote)
                                            }
                                            .padding(6)
                                            .frame(minWidth: 150, minHeight: 80)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color("sharkPrimaryColor"), lineWidth: 1)
                                            )
                                            .position(x: x + xOffset, y: y + yOffset)
                                            
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.leading, 4)
                    
                    

                    // 가로축 기준선
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)

                    HStack {
                        Text(shortDate(startDate))
                        Spacer()
                        Text(shortDate(oneThirdDate))
                        Spacer()
                        Text(shortDate(twoThirdDate))
                        Spacer()
                        Text(shortDate(lastDate))
                    }
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.leading, 35)
                }
                .padding()
            } else {
                Text("데이터가 부족합니다.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy. M. d"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
struct WeightChartView: View {
    let data: [(date: Date, weight: Double)]
    let startDate: Date
    let endDate: Date
    
    @State private var selectedEntry: (date: Date, weight: Double)? = nil

    var body: some View {
        GeometryReader { geometry in
            let filteredData = data.filter { $0.date >= startDate && $0.date <= endDate }
            let sortedData = filteredData.sorted { $0.date < $1.date }

            if let lastDate = sortedData.last?.date,
               let minWeight = sortedData.map({ $0.weight }).min(),
               let maxWeight = sortedData.map({ $0.weight }).max(),
               maxWeight > minWeight {

                let totalInterval = endDate.timeIntervalSince(startDate)
                let intervalStep = totalInterval / 9.0
                let desiredDates: [Date] = (0..<10).map {
                    startDate.addingTimeInterval(Double($0) * intervalStep)
                }

                let cappedData: [(date: Date, weight: Double)] = desiredDates.compactMap { targetDate in
                    sortedData.min(by: {
                        //절댓값
                        abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
                    })
                }

                let firstDate = startDate
                let dateRange = endDate.timeIntervalSince(firstDate)
                let weightRange = maxWeight - minWeight
                let oneThirdDate = firstDate.addingTimeInterval(dateRange / 3)
                let twoThirdDate = firstDate.addingTimeInterval(dateRange * 2 / 3)
                let roundedMin = floor(minWeight)
                let roundedMax = ceil(maxWeight)

                VStack(spacing: 8) {
                    HStack(alignment: .top) {
                        VStack {
                            Text("\(Int(roundedMax))")
                            Spacer()
                            Text("\(Int(roundedMax - weightRange * 1/3))")
                            Spacer()
                            Text("\(Int(roundedMax - weightRange * 2/3))")
                            Spacer()
                            Text("\(Int(roundedMin))")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 30)
                        // 세로축 기준선
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1)

                        ZStack(alignment: .topTrailing) {
                            GeometryReader { geo in
                                let width = geo.size.width
                                let height = geo.size.height

                                ZStack {
                                    // 전체 흐릿한 선
                                    Path { path in
                                        for (index, entry) in sortedData.enumerated() {
                                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                            let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                            index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                    .stroke(Color("sharkPrimaryColor").opacity(0.3), lineWidth: 1)

                                    // 강조된 선
                                    Path { path in
                                        for (index, entry) in cappedData.enumerated() {
                                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                            let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                            index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                    .stroke(Color("sharkPrimaryColor"), lineWidth: 2)

                                    // 강조된 점
                                    ForEach(cappedData, id: \.date) { entry in
                                        let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                        let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                        Circle()
                                            .fill(selectedEntry?.date == entry.date ? Color("food") : Color("sharkPrimaryColor"))
                                            .frame(width: 10, height: 10)
                                            .position(x: x, y: y)
                                            .onTapGesture {
                                                if selectedEntry?.date == entry.date {
                                                    selectedEntry = nil
                                                } else {
                                                    selectedEntry = entry
                                                }
                                            }
                                    }
                                    ForEach(cappedData, id: \.date) { entry in
                                        if let entry = selectedEntry {
                                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                            let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                            let yOffset: CGFloat = y > height / 2 ? -50 : 50
                                            
                                            let toStart = abs(entry.date.timeIntervalSince(startDate))
                                            let toEnd = abs(entry.date.timeIntervalSince(endDate))
                                            let xOffset: CGFloat = toStart < toEnd ? 30 : -30
                                            VStack(alignment: .leading) {
                                                Text("날짜 : \(longDate(entry.date))")
                                                    .font(.footnote)
                                                Text("키 : \(String(format: "%.1f", entry.weight))kg")
                                                    .font(.footnote)
                                            }
                                            .padding(6)
                                            .frame(minWidth: 150, minHeight: 80)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color("sharkPrimaryColor"), lineWidth: 1)
                                            )
                                            .position(x: x + xOffset, y: y + yOffset)
                                            
                                        }
                                    }
                                    

                                    
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.leading, 4)

                    // 가로축 기준선
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)

                    HStack {
                        Text(shortDate(startDate))
                        Spacer()
                        Text(shortDate(oneThirdDate))
                        Spacer()
                        Text(shortDate(twoThirdDate))
                        Spacer()
                        Text(shortDate(lastDate))
                    }
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.leading, 35)
                }
                .padding()
            } else {
                Text("데이터가 부족합니다.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy. M. d"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
struct DateRangeSelectView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    @State private var showStartPicker: Bool = false
    @State private var showEndPicker: Bool = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yy. M. d"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 25) {
            
            HStack(alignment: .center) {
                // 시작 날짜 선택
                HStack {
                    Text("\(dateFormatter.string(from: startDate))")
                        .foregroundColor(.primary)
                        .padding(.vertical, 12)
                        .padding(.leading, 12)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(Color("sharkPrimaryColor"))
                        .padding(.trailing, 12)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                )
                .padding(.horizontal)
                .onTapGesture {
                    showStartPicker = true
                }
                .sheet(isPresented: $showStartPicker) {
                    VStack {
                        DatePicker("시작일", selection: $startDate, in: ...endDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                        Button("완료") {
                            showStartPicker = false
                        }
                        .padding()
                    }
                    .padding()
                    .presentationDetents([.height(500)])
                    .presentationDragIndicator(.visible)
                }
                Spacer()
                Text("~")
                Spacer()
                
                // 종료 날짜 선택
                HStack {
                    Text("\(dateFormatter.string(from: endDate))")
                        .foregroundColor(.primary)
                        .padding(.vertical, 12)
                        .padding(.leading, 12)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(Color("sharkPrimaryColor"))
                        .padding(.trailing, 12)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                )
                .padding(.horizontal)
                .onTapGesture {
                    showEndPicker = true
                }
                .sheet(isPresented: $showEndPicker) {
                    VStack {
                        DatePicker("종료일", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                        Button("완료") {
                            showEndPicker = false
                        }
                        .padding()
                    }
                    .padding()
                    .presentationDetents([.height(500)])
                    .presentationDragIndicator(.visible)
                }
            }
            
            
        }
    }
}
