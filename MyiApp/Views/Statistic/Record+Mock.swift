//
//  Record+Mock.swift
//  MyiApp
//
//  Created by 이민서 on 5/12/25.
//

import Foundation

import Foundation

extension Record {
    static let mockTestRecords: [Record] = {
        let korea = TimeZone(identifier: "Asia/Seoul")!
        var calendar = Calendar.current
        calendar.timeZone = korea

        return [
            Record(
                id: UUID(uuidString: "5ab9a456-5602-4a33-a98b-0906ea0f9b76")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 23, minute: 19, second: 47))!,
                title: .babyFood,
                mlAmount: 120
            ),
            Record(
                id: UUID(uuidString: "45a5d3cd-8ce7-4466-b927-0f02762244e2")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 5, minute: 48, second: 11))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 9,
                breastfeedingRightMinutes: 10
            ),
            Record(
                id: UUID(uuidString: "a45cee75-ae72-4c59-8a5c-fb5f3e4b732c")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 8, minute: 37, second: 0))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 6,
                breastfeedingRightMinutes: 8
            ),
            Record(
                id: UUID(uuidString: "4ed71035-6eae-491b-8ddd-d3e504d48cc2")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 4, minute: 20, second: 0))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 5,
                breastfeedingRightMinutes: 60
            ),
            Record(
                id: UUID(uuidString: "b48a3aef-d714-4c85-b41d-62fef762e146")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 14, minute: 50, second: 0))!,
                title: .breastfeeding,
                breastfeedingLeftMinutes: 6,
                breastfeedingRightMinutes: 9
            ),
            Record(
                id: UUID(uuidString: "856b31d5-a9f4-4bca-b5ef-a5c00eec7401")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 150
            ),
            Record(
                id: UUID(uuidString: "856b31d5-a9f4-4bca-b5ef-a5c00eec7401")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 19, minute: 54, second: 25))!,
                title: .formula,
                mlAmount: 150
            ),
            
            
            Record(
                id: UUID(uuidString: "e59b952a-aa9c-4c08-9308-84f4a234ed8c")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 5, minute: 49, second: 23))!,
                title: .heightWeight,
                height: 68.5,
                weight: 8.8
            ),
            
            
            
            
            Record(
                id: UUID(uuidString: "4cb85058-683c-431d-a0e4-93a1a400a74c")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 15, minute: 19, second: 41))!,
                title: .snack,
                snackContent: "퓨레"
            ),
            
            
            
            
            Record(
                id: UUID(uuidString: "4ed71035-6eae-491b-8ddd-d3e504d48cc2")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 4, minute: 20, second: 0))!,
                title: .diaper
            ),
            Record(
                id: UUID(uuidString: "4ed71035-6eae-491b-8ddd-d3e504d48cc2")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 14, minute: 20, second: 0))!,
                title: .diaper
            ),
            Record(
                id: UUID(uuidString: "4ed71035-6eae-491b-8ddd-d3e504d48cc2")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 16, minute: 20, second: 0))!,
                title: .diaper
            ),
            
            
            Record(
                id: UUID(uuidString: "4ed71035-6eae-491b-8ddd-d3e504d48cc2")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 14, minute: 20, second: 0))!,
                title: .bath
            ),
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000008")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 14, minute: 00, second: 0))!,
                title: .bath
            ),
            
            
            
            
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000007")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 9, minute: 8, second: 0))!,
                title: .sleep,
                sleepStart: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 23, minute: 30, second: 0))!,
                sleepEnd: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 2, minute: 12, second: 3))!
            ),
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000006")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 9, minute: 8, second: 0))!,
                title: .sleep,
                sleepStart: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 21, minute: 30, second: 0))!,
                sleepEnd: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 3, minute: 12, second: 3))!
            ),
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000005")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 9, minute: 8, second: 0))!,
                title: .sleep,
                sleepStart: calendar.date(from: DateComponents(year: 2025, month: 5, day: 13, hour: 22, minute: 00, second: 0))!,
                sleepEnd: calendar.date(from: DateComponents(year: 2025, month: 5, day: 14, hour: 2, minute: 00, second: 3))!
            ),
            
            
            
            
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000001")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 12, hour: 7, minute: 30))!,
                title: .potty,
                pottyType: .poop
            ),
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000004")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 7, minute: 30))!,
                title: .potty,
                pottyType: .poop
            ),
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000002")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 10, minute: 45))!,
                title: .potty,
                pottyType: .pee
            ),
            Record(
                id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000003")!,
                createdAt: calendar.date(from: DateComponents(year: 2025, month: 5, day: 11, hour: 8, minute: 15))!,
                title: .potty,
                pottyType: .all
            ),

        ]
    }()
}
