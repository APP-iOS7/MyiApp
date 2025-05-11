//
//  Date+Extenstion.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-11.
//

import Foundation

extension Date {
    
    func to24HourTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR") // 24시간제 보장
        formatter.dateFormat = "HH:mm" // 24시간제 포맷
        return formatter.string(from: self)
    }
    
    func formattedKoreanDateString() -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            
            if Calendar.current.isDateInToday(self) {
                formatter.dateFormat = "MM월 dd일 '(오늘)'"
            } else {
                formatter.dateFormat = "MM월 dd일 (E)"
            }
            
            return formatter.string(from: self)
        }
}
