//
//  WeightChartView.swift
//  MyiApp
//
//  Created by 이민서 on 5/29/25.
//

import SwiftUI

struct WeightChartView: View {
    let data: [(date: Date, weight: Double)]
    let startDate: Date
    let endDate: Date
    
    @Binding var selectedEntry: WeightEntry?

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
                
                GeometryReader { geo in
                    let width = geo.size.width
                    VStack() {
                        if let entry = selectedEntry {
                            let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                            
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
                                    .stroke(Color("buttonColor"), lineWidth: 1)
                            )
                            .position(x: x + xOffset, y: 40)
                            
                        }
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

                                            // 선
                                            Path { path in
                                                for (index, entry) in cappedData.enumerated() {
                                                    let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                                    let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                                    index == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                                                }
                                            }
                                            .stroke(Color("buttonColor"), lineWidth: 2)

                                            // 강조된 점
                                            ForEach(cappedData, id: \.id) { entry in
                                                let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                                let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                                Circle()
                                                    .fill(Color("buttonColor"))
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
                                            // 선택된 점의 선
                                            if let entry = selectedEntry {
                                                let x = CGFloat(entry.date.timeIntervalSince(firstDate) / dateRange) * width
                                                let y = height - ((CGFloat(entry.weight - minWeight) / CGFloat(weightRange)) * height)
                                                
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 1, height: y - 10)
                                                    .position(x: x, y: y / 2)
                                                    .zIndex(-1)
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
                        .offset(y: selectedEntry == nil ? 0 : 100)
                        .animation(.easeInOut, value: selectedEntry)
                    }
                }
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
