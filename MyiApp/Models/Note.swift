//
//  Note.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 2025-05-13.
//

import Foundation

struct CalendarDay: Identifiable {
    var id: UUID
    var date: Date?
    var dayNumber: String
    var isToday: Bool
    var isCurrentMonth: Bool
}

struct Note: Identifiable, Hashable, Codable {
    var id: UUID
    var title: String
    var description: String
    var date: Date
    var category: NoteCategory
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}

enum NoteCategory: String, CaseIterable, Hashable, Codable {
    case 일지 = "일지"
    case 일정 = "일정"
}
