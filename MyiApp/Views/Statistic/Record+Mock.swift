//
//  Record+Mock.swift
//  MyiApp
//
//  Created by 이민서 on 5/12/25.
//

import Foundation

extension Record {
    static let mockTestRecords: [Record] = {
        let korea = TimeZone(identifier: "Asia/Seoul")!
        var calendar = Calendar.current
        calendar.timeZone = korea

        return [
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 23, minute: 19, second: 47))!,
                title: .babyFood,
                mlAmount: 120
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 4, day: 13, hour: 23, minute: 19, second: 47))!,
                title: .babyFood,
                mlAmount: 120
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 18, hour: 23, minute: 19, second: 47))!,
                title: .babyFood,
                mlAmount: 120
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 14, hour: 23, minute: 19, second: 47))!,
                title: .babyFood,
                mlAmount: 60
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 14, hour: 23, minute: 19, second: 47))!,
                title: .babyFood,
                mlAmount: 120
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 5, minute: 48, second: 11))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 9,
                breastfeedingRightMinutes: 10
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 4, day: 12, hour: 5, minute: 48, second: 11))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 9,
                breastfeedingRightMinutes: 10
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 8, minute: 37, second: 0))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 6,
                breastfeedingRightMinutes: 8
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 4, minute: 20, second: 0))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 5,
                breastfeedingRightMinutes: 5
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 14, minute: 50, second: 0))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 6,
                breastfeedingRightMinutes: 9
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 4, day: 11, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 20
            ),

            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 14, minute: 00, second: 0))!,
                title: .pumpedMilk,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 4, day: 11, hour: 14, minute: 00, second: 0))!,
                title: .pumpedMilk,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 14, minute: 00, second: 0))!,
                title: .pumpedMilk,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 14, minute: 00, second: 0))!,
                title: .pumpedMilk,
                mlAmount: 150
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 14, minute: 00, second: 0))!,
                title: .pumpedMilk,
                mlAmount: 150
            ),
            
            
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 5, minute: 49, second: 23))!,
                title: .heightWeight,
                height: 68.5,
                weight: 8.8
            ),
            
            
            
            
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 15, minute: 19, second: 41))!,
                title: .snack,
                content: "퓨레"
            ),
            
            
            
            
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 4, minute: 20, second: 0))!,
                title: .diaper
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 14, minute: 20, second: 0))!,
                title: .diaper
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 16, minute: 20, second: 0))!,
                title: .diaper
            ),
            
            
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 14, minute: 20, second: 0))!,
                title: .bath
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 14, minute: 00, second: 0))!,
                title: .bath
            ),
            
            
            
            
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 9, minute: 8, second: 0))!,
                title: .sleep,
                sleepStart: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 23, minute: 30, second: 0))!,
                sleepEnd: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 2, minute: 12, second: 3))!
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 9, minute: 8, second: 0))!,
                title: .sleep,
                sleepStart: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 21, minute: 30, second: 0))!,
                sleepEnd: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 3, minute: 12, second: 3))!
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 9, minute: 8, second: 0))!,
                title: .sleep,
                sleepStart: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 22, minute: 00, second: 0))!,
                sleepEnd: calendar.date(from: DateComponents(year: 2025, month: 5, day: 14, hour: 2, minute: 00, second: 3))!
            ),
            
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 7, minute: 30))!,
                title: .poop
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 7, minute: 30))!,
                title: .poop
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 10, minute: 45))!,
                title: .pee
            ),
            Record(
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 8, minute: 15))!,
                title: .pottyAll
            ),

        ]
    }()
}
