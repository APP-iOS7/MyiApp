//
//  NoteEvent.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/12/25.
//

import SwiftUI

struct NoteEventRow: View {
    var event: Note
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(categoryColor(for: event.category))
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(event.timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("sharkCardBackground"))
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func categoryColor(for category: NoteCategory) -> Color {
        switch category {
        case .건강:
            return Color.green.opacity(0.8)
        case .발달:
            return Color.orange.opacity(0.8)
        case .식사:
            return Color.purple.opacity(0.8)
        case .일상:
            return Color("sharkPrimaryLight")
        case .기타:
            return Color.gray.opacity(0.6)
        }
    }
}

struct NoteEventList: View {
    var events: [Note]
    var filteredCategory: NoteCategory?
    var onSelectEvent: ((Note) -> Void)
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let filteredEvents = filteredCategory == nil ? events : events.filter { $0.category == filteredCategory }
                
                if filteredEvents.isEmpty {
                    VStack {
                        Spacer()
                        Text("해당 카테고리의 기록이 없습니다.")
                            .foregroundColor(.gray)
                            .padding(.top, 60)
                        Spacer()
                    }
                    .frame(height: 200)
                } else {
                    ForEach(filteredEvents) { event in
                        NoteEventRow(event: event) {
                            onSelectEvent(event)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

#Preview {
    VStack {
        NoteEventRow(
            event: Note(
                id: UUID(),
                title: "체중 측정",
                description: "오늘 몸무게: 8.2kg, 전주 대비 +200g 증가",
                date: Date(),
                category: .건강
            )
        )
        
        NoteEventRow(
            event: Note(
                id: UUID(),
                title: "첫 걸음마",
                description: "오늘 아기가 처음으로 3걸음을 혼자 걸었어요!",
                date: Date().addingTimeInterval(-3600),
                category: .발달
            )
        )
        
        NoteEventRow(
            event: Note(
                id: UUID(),
                title: "이유식 시작",
                description: "오늘부터 계란노른자를 추가한 이유식을 시작했어요.",
                date: Date().addingTimeInterval(-7200),
                category: .식사
            )
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
