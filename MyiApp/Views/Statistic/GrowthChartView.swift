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
                Divider()
                VStack(spacing: 10) {
                    if (selectedMode == "키") {
                        lastHeightInfoView(
                            data: heightData
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                    } else {
                        lastWeightInfoView(
                            data: weightData
                        )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 20)
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

struct HeightChartView: View {
    let data: [(date: Date, height: Double)]
    let startDate: Date
    let endDate: Date
    
    @State private var selectedEntry: HeightEntry? = nil

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

                let cappedData: [HeightEntry] = desiredDates.enumerated().compactMap { (idx, targetDate) in
                    sortedData.min(by: {
                        //절댓값
                        abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
                    }).map { entry in
                        HeightEntry(index: idx, date: entry.date, height: entry.height)
                    }
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
                                    ForEach(cappedData, id: \.id) { entry in
                                        let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                        let y = height - ((CGFloat(entry.height - minHeight) / CGFloat(heightRange)) * height)
                                        Circle()
                                            .fill(selectedEntry?.id == entry.id ? Color("buttonColor") : Color("sharkPrimaryColor"))
                                            .frame(width: 10, height: 10)
                                            .position(x: x, y: y)
                                            .onTapGesture {
                                                if selectedEntry?.id == entry.id {
                                                    selectedEntry = nil
                                                } else {
                                                    selectedEntry = entry
                                                }
                                            }
                                        
                                    }
                                    if let entry = selectedEntry {
                                        let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                        let y = height - ((CGFloat(entry.height - minHeight) / CGFloat(heightRange)) * height)
                                        let yOffset: CGFloat = y > height / 2 ? -50 : 50
                                        
                                        let toStart = abs(entry.date.timeIntervalSince(startDate))
                                        let toEnd = abs(entry.date.timeIntervalSince(endDate))
                                        let xOffset: CGFloat = toStart < toEnd ? 50 : -50
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
    
    @State private var selectedEntry: WeightEntry? = nil

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

                let cappedData: [WeightEntry] = desiredDates.enumerated().compactMap { (idx, targetDate) in
                    sortedData.min(by: {
                        //절댓값
                        abs($0.date.timeIntervalSince(targetDate)) < abs($1.date.timeIntervalSince(targetDate))
                    }).map { entry in
                        WeightEntry(index: idx, date: entry.date, weight: entry.weight)
                    }
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
                                    ForEach(cappedData, id: \.id) { entry in
                                        let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                        let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                        Circle()
                                            .fill(selectedEntry?.id == entry.id ? Color("buttonColor") : Color("sharkPrimaryColor"))
                                            .frame(width: 10, height: 10)
                                            .position(x: x, y: y)
                                            .onTapGesture {
                                                if selectedEntry?.id == entry.id {
                                                    selectedEntry = nil
                                                } else {
                                                    selectedEntry = entry
                                                }
                                            }
                                    }
                                    if let entry = selectedEntry {
                                        let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                        let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                        let yOffset: CGFloat = y > height / 2 ? -50 : 50
                                        
                                        let toStart = abs(entry.date.timeIntervalSince(startDate))
                                        let toEnd = abs(entry.date.timeIntervalSince(endDate))
                                        let xOffset: CGFloat = toStart < toEnd ? 50 : -50
                                        VStack(alignment: .leading) {
                                            Text("날짜 : \(longDate(entry.date))")
                                                .font(.footnote)
                                            Text("몸무게 : \(String(format: "%.1f", entry.weight))kg")
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
                ZStack {
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
                    DatePicker(
                        "",
                        selection: $startDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(width: 180, height: 30)
                    .blendMode(.destinationOver)
                }
                
                Spacer()
                Text("~")
                Spacer()
                
                // 종료 날짜 선택
                ZStack {
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
                    DatePicker(
                        "",
                        selection: $endDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(width: 180, height: 30)
                    .blendMode(.destinationOver)
                }
                
            }
            
            
        }
    }
}
struct lastHeightInfoView: View {
    let data: [(date: Date, height: Double)]
    
    var body: some View {
        if let recent = data.sorted(by: { $0.date > $1.date }).first {
            VStack(spacing: 4) {
                Text("최근 키 측정")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text("\(longDate(recent.date)) / \(String(format: "%.1f", recent.height))cm")
                    .font(.subheadline)
            }
        }
    }
    func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
struct lastWeightInfoView: View {
    let data: [(date: Date, weight: Double)]
    
    var body: some View {
        if let recent = data.sorted(by: { $0.date > $1.date }).first {
            VStack(spacing: 4) {
                Text("최근 키 측정")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text("\(longDate(recent.date)) / \(String(format: "%.1f", recent.weight))kg")
                    .font(.subheadline)
            }
        }
    }
    func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
