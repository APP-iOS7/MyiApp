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
                    ForEach(0..<min(events.count, maxDots), id: \.self) { _ in
                        Circle()
                            .fill(Color("sharkPrimaryLight"))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .frame(height: 10)
            .padding(.top, 2),
            alignment: .bottom
        )
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
                        // 생일인 경우 특별한 스타일 적용
                        Circle()
                            .stroke(Color.pink, lineWidth: 1.5)
                            .frame(width: 35, height: 35)
                    }
                    
                    VStack(spacing: 0) {
                        if isBirthday && !isSelected {
                            // 생일 케이크 이모지 (선택되지 않은 경우에만)
                            Text("🎂")
                                .font(.system(size: 8))
                                .padding(.bottom, 1)
                        }
                        
                        Text(day.dayNumber)
                            .font(.system(size: isSelected ? 18 : 16, weight: isSelected ? .bold : .regular))
                            .foregroundColor(
                                isSelected ? .white :
                                    isBirthday ? .pink :
                                    isSunday && day.isCurrentMonth ? .red :
                                    isSaturday && day.isCurrentMonth ? .blue :
                                        day.isToday ? Color("sharkPrimaryDark") :
                                            day.isCurrentMonth ? .primary : .gray
                            )
                    }
                }
                .frame(width: 35, height: 35)
                
                // 이벤트 도트 개선 - 날짜 아래에 일관된 위치로 표시
                HStack(spacing: 4) {
                    ForEach(0..<min(events.count, 3), id: \.self) { _ in
                        Circle()
                            .fill(Color("sharkPrimaryLight"))
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 10)
                .opacity(day.isCurrentMonth ? 1 : 0.5) // 현재 달이 아닌 날짜는 투명도 낮게
            } else {
                // 빈 날짜칸
                Text("")
                    .frame(width: 35, height: 35)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 10)
            }
        }
        .frame(height: 50)
        .contentShape(Rectangle()) // 전체 영역을 탭 가능하게
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
                Note(id: UUID(), title: "테스트", description: "설명", date: Date(), category: .일상),
                Note(id: UUID(), title: "테스트2", description: "설명2", date: Date(), category: .건강)
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
