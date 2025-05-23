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
        VStack(spacing: 2) {
            if let date = day.date {
                let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
                let weekday = Calendar.current.component(.weekday, from: date)
                let isSunday = weekday == 1
                let isSaturday = weekday == 7
                
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.button)
                            .frame(width: 36, height: 36)
                    } else if day.isToday {
                        Circle()
                            .stroke(Color("sharkPrimaryDark"), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                    } else if isBirthday {
                        Circle()
                            .stroke(Color.pink, lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                    }
                    
                    VStack(spacing: 0) {
                        if isBirthday && !isSelected {
                            Text("🎂")
                                .font(.system(size: 8))
                                .padding(.bottom, 1)
                        }
                        
                        Text(day.dayNumber)
                            .font(.title3)
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
                .frame(width: 36, height: 36)
                
                // MARK: - 이벤트 도트
                HStack(spacing: 2) {
                    // 일지 도트
                    if events.contains(where: { $0.category == .일지 }) {
                        Circle()
                            .fill(.button)
                            .frame(width: 5, height: 5)
                    }
                    
                    // 일정 도트
                    if events.contains(where: { $0.category == .일정 }) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
                .opacity(day.isCurrentMonth ? 1 : 0.5)
            } else {
                VStack(spacing: 2) {
                    Text("")
                        .frame(width: 36, height: 36)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .contentShape(Rectangle())
    }
}
