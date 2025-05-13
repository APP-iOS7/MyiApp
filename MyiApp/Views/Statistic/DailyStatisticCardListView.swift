//
//  DailyStatisticCardListView.swift
//  MyiApp
//
//  Created by 이민서 on 5/12/25.
//

import SwiftUI

struct DailyStatisticCardListView: View {
    
    let records: [Record]
    let selectedDate: Date
    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
    }
    
    
    var body: some View {
        let pottyCount = countPottyTypes(in: records, on: selectedDate)
        let yesterdaypottyCount = countPottyTypes(in: records, on: yesterday)
        
        Group {
            StatisticCardView(
                title: "분유/수유/이유식 통계",
                image: .colorMeal,
                color: Color("food"),
                count: combinedFeedCount(in: records, on: selectedDate),
                lastcount: combinedFeedCount(in: records, on: yesterday),
                amount: totalMlAmount(in: records, on: selectedDate),
                lastamount: totalMlAmount(in: records, on: yesterday),
                time: totalBreastfeedingMinutes(in: records, on: selectedDate),
                lasttime: totalBreastfeedingMinutes(in: records, on: yesterday),
                mode : "daily"
            )
            
            StatisticCardView(
                title: "기저귀 통계",
                image: .colorDiaper,
                color: Color("diaper"),
                count: recordsCount(for: .diaper, in: records, on: selectedDate),
                lastcount: recordsCount(for: .diaper, in: records, on: yesterday),
                amount: nil,
                lastamount: nil,
                time: nil,
                lasttime: nil,
                mode : "daily"
            )
            PottyStatisticCardView(
                small: pottyCount.small,
                yesterdaysmall: yesterdaypottyCount.small,
                big: pottyCount.big,
                yesterdaybig: yesterdaypottyCount.big,
                mode : "daily"
            )
            
            StatisticCardView(
                title: "수면 통계",
                image: .colorSleep,
                color: Color("sleep"),
                count: recordsCount(for: .sleep, in: records, on: selectedDate),
                lastcount: recordsCount(for: .sleep, in: records, on: yesterday),
                amount: nil,
                lastamount: nil,
                time: totalSleepMinutes(in: records, on: selectedDate),
                lasttime: totalSleepMinutes(in: records, on: yesterday),
                mode : "daily"
            )
            
            StatisticCardView(
                title: "목욕 통계",
                image: .colorBath,
                color: Color("bath"),
                count: recordsCount(for: .bath, in: records, on: selectedDate),
                lastcount: recordsCount(for: .bath, in: records, on: yesterday),
                amount: nil,
                lastamount: nil,
                time: nil,
                lasttime: nil,
                mode : "daily"
            )
            
            StatisticCardView(
                title: "간식 통계",
                image: .colorSnack,
                color: Color("snack"),
                count: recordsCount(for: .snack, in: records, on: selectedDate),
                lastcount: recordsCount(for: .snack, in: records, on: yesterday),
                amount: nil,
                lastamount: nil,
                time: nil,
                lasttime: nil,
                mode : "daily"
            )
        }
        .padding(.horizontal)
    }
    // 카테고리 받아서 횟수 셀리기
    func recordsCount(for title: TitleCategory, in records: [Record], on date: Date) -> Int {
        let calendar = Calendar.current
        return records.filter {
            $0.title == title && calendar.isDate($0.createdAt, inSameDayAs: date)
        }.count
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
    // 소변,배변 횟수 따로 셀리기
    func countPottyTypes(in records: [Record], on date: Date) -> (small: Int, big: Int) {
        let calendar = Calendar.current
        
        var small = 0
        var big = 0
        
        for record in records {
            guard record.title == .potty,
                  calendar.isDate(record.createdAt, inSameDayAs: date),
                  let type = record.pottyType else { continue }
            
            switch type {
            case .pee:
                small += 1
            case .poop:
                big += 1
            case .all:
                small += 1
                big += 1
            }
        }
        
        return (small, big)
    }
    // 수면 시간 총계
    func totalSleepMinutes(in records: [Record], on date: Date) -> Int? {
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let totalMinutes = records
            .filter { $0.title == .sleep }
            .compactMap { record -> Int? in
                guard let start = record.sleepStart, let end = record.sleepEnd else { return nil }
                
                let clippedStart = max(start, startOfDay)
                let clippedEnd = min(end, endOfDay)
                
                let interval = clippedEnd.timeIntervalSince(clippedStart)
                return interval > 0 ? Int(interval / 60) : nil
            }
            .reduce(0, +)
        
        return totalMinutes > 0 ? totalMinutes : nil
    }
}
