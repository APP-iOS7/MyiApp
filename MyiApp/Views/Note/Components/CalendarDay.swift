//
//  CalendarDay.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/12/25.
//

import SwiftUI

extension View {
    func withEventDots(events: [Note], maxDots: Int = 3) -> some View {
        self.overlay(
            HStack(spacing: 4) {
                if !events.isEmpty {
                    let categories = Set(events.map { $0.category })
                    ForEach(Array(categories.prefix(maxDots)), id: \.self) { category in
                        Circle()
                            .fill(categoryColor(for: category))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(height: 10)
            .padding(.top, 2),
            alignment: .bottom
        )
    }
    
    private func categoryColor(for category: NoteCategory) -> Color {
        switch category {
        case .일지:
            return Color("sharkPrimaryColor")
        case .일정:
            return Color.orange
        }
    }
}

struct CalendarDayView: View {
    var day: CalendarDay
    @Binding var selectedDate: Date?
    var events: [Note]
    var isBirthday: Bool
    
    var body: some View {
        VStack(spacing: 3) {
            if let date = day.date {
                let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
                let weekday = Calendar.current.component(.weekday, from: date)
                let isSunday = weekday == 1
                let isSaturday = weekday == 7
                
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color("sharkPrimaryColor"))
                            .frame(width: 35, height: 35)
                    } else if day.isToday {
                        Circle()
                            .stroke(Color("sharkPrimaryDark"), lineWidth: 1.5)
                            .frame(width: 35, height: 35)
                    } else if isBirthday {
                        Circle()
                            .stroke(Color.pink, lineWidth: 1.5)
                            .frame(width: 35, height: 35)
                    }
                    
                    VStack(spacing: 0) {
                        if isBirthday && !isSelected {
                            Text("🎂")
                                .font(.system(size: 8))
                                .padding(.bottom, 1)
                        }
                        
                        Text(day.dayNumber)
                            .font(.system(size: 18))
                            .foregroundColor(
                                isSelected ? .white :
                                    isBirthday ? .pink :
                                    isSunday && day.isCurrentMonth ? .red.opacity(day.isCurrentMonth ? 1 : 0.5) :
                                    isSaturday && day.isCurrentMonth ? .blue.opacity(day.isCurrentMonth ? 1 : 0.5) :
                                        day.isToday ? Color("sharkPrimaryDark") :
                                            day.isCurrentMonth ? .primary : .secondary
                            )
                    }
                }
                .frame(width: 35, height: 35)
                
                // 이벤트 도트
                HStack(spacing: 4) {
                    // 일지 도트
                    if events.contains(where: { $0.category == .일지 }) {
                        Circle()
                            .fill(Color("sharkPrimaryColor"))
                            .frame(width: 6, height: 6)
                    }
                    
                    // 일정 도트
                    if events.contains(where: { $0.category == .일정 }) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 10)
                .opacity(day.isCurrentMonth ? 1 : 0.5)
            } else {
                Text("")
                    .frame(width: 35, height: 35)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 10)
            }
        }
        .frame(height: 50)
        .contentShape(Rectangle())
    }
}

#Preview {
    HStack {
        // 일반 날짜
        CalendarDayView(
            day: CalendarDay(id: UUID(), date: Date(), dayNumber: "15", isToday: false, isCurrentMonth: true),
            selectedDate: .constant(nil),
            events: [],
            isBirthday: false
        )
        
        // 오늘
        CalendarDayView(
            day: CalendarDay(id: UUID(), date: Date(), dayNumber: "12", isToday: true, isCurrentMonth: true),
            selectedDate: .constant(nil),
            events: [],
            isBirthday: false
        )
        
        // 선택된 날짜
        CalendarDayView(
            day: CalendarDay(id: UUID(), date: Date(), dayNumber: "10", isToday: false, isCurrentMonth: true),
            selectedDate: .constant(Date()),
            events: [],
            isBirthday: false
        )
        
        // 이벤트가 있는 날짜
        CalendarDayView(
            day: CalendarDay(id: UUID(), date: Date().addingTimeInterval(86400), dayNumber: "16", isToday: false, isCurrentMonth: true),
            selectedDate: .constant(nil),
            events: [
                Note(id: UUID(), title: "테스트", description: "설명", date: Date(), category: .일지),
                Note(id: UUID(), title: "테스트2", description: "설명2", date: Date(), category: .일정)
            ],
            isBirthday: false
        )
        
        // 생일
        CalendarDayView(
            day: CalendarDay(id: UUID(), date: Date().addingTimeInterval(172800), dayNumber: "19", isToday: false, isCurrentMonth: true),
            selectedDate: .constant(nil),
            events: [],
            isBirthday: true
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
