//
//  NoteView.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI

struct NoteView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingNoteEditor = false
    @State private var selectedDate: Date? = nil
    @State private var selectedFilterCategory: NoteCategory? = nil
    @State private var selectedEvent: Note? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text(viewModel.currentMonth)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.selectedMonth = Date()
                        viewModel.fetchCalendarDays()
                        
                        let today = Calendar.current.startOfDay(for: Date())
                        if let todayDay = viewModel.days.first(where: { $0.isToday }) {
                            selectedDate = today
                            viewModel.selectedDay = todayDay
                        }
                    }) {
                        Text("오늘")
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundColor(.white)
                            .background(Capsule().fill(Color("sharkPrimaryColor")))
                    }
                    
                    Button(action: {
                        viewModel.changeMonth(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 6)
                    
                    Button(action: {
                        viewModel.changeMonth(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                HStack(spacing: 0) {
                    ForEach(viewModel.weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(day == "일" ? .red : day == "토" ? .blue : .primary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("sharkCardBackground"))
            )
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(viewModel.days) { day in
                    CalendarDayView(
                        day: day,
                        selectedDate: $selectedDate,
                        events: viewModel.getEventsForDay(day)
                    )
                    .onTapGesture {
                        if day.date != nil {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDate = day.date
                                viewModel.selectedDay = day
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            selectedFilterCategory = nil
                        }) {
                            Text("전체")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedFilterCategory == nil ? Color("sharkPrimaryColor") : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedFilterCategory == nil ? .white : .primary)
                        }
                        
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedFilterCategory = category
                            }) {
                                Text(category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedFilterCategory == category ? Color("sharkPrimaryColor") : Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(selectedFilterCategory == category ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                if let selectedDay = viewModel.selectedDay, let date = selectedDay.date {
                    HStack {
                        Text("\(date.formattedFullKoreanDateString())")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingNoteEditor = true
                        }) {
                            Label("추가", systemImage: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color("sharkPrimaryDark"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if let events = viewModel.events[Calendar.current.startOfDay(for: date)] {
                                let filteredEvents = selectedFilterCategory == nil ? events : events.filter { $0.category == selectedFilterCategory }
                                
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
                                        Button {
                                            selectedEvent = event
                                        } label: {
                                            NoteEventRow(event: event)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.bottom, 16)
                                }
                            } else {
                                VStack {
                                    Spacer()
                                    Text("기록된 일지가 없습니다.")
                                        .foregroundColor(.gray)
                                        .padding(.top, 60)
                                    Spacer()
                                }
                                .frame(height: 200)
                            }
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("날짜를 선택해주세요.")
                            .foregroundColor(.gray)
                            .padding(.top, 60)
                        Spacer()
                    }
                    .frame(height: 200)
                }
            }
            
            Spacer()
        }
        .navigationTitle("육아 수첩")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("검색", systemImage: "magnifyingglass")
                    }
                    
                    Button(action: {}) {
                        Label("카테고리 필터", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: {}) {
                        Label("정렬", systemImage: "arrow.up.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(selectedDate: viewModel.selectedDay?.date ?? Date())
        }
        .navigationDestination(item: $selectedEvent) { event in
            NoteDetailView(event: event)
        }
    }
}

struct CalendarDayView: View {
    var day: CalendarDay
    @Binding var selectedDate: Date?
    var events: [Note]
    
    var body: some View {
        VStack(spacing: 3) {
            if let date = day.date {
                let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
                
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color("sharkPrimaryColor"))
                            .frame(width: 35, height: 35)
                    } else if day.isToday {
                        Circle()
                            .stroke(Color("sharkPrimaryDark"), lineWidth: 1.5)
                            .frame(width: 35, height: 35)
                    }
                    
                    Text(day.dayNumber).font(.custom("Cafe24-Ohsquareair", size: isSelected ? 18 : 16))
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundColor(isSelected ? .white : day.isToday ? Color("sharkPrimaryDark") : day.isCurrentMonth ? .primary : .gray)
                }
                .frame(width: 35, height: 35)
                
                HStack(spacing: 4) {
                    if !events.isEmpty {
                        ForEach(0..<min(events.count, 3), id: \.self) { _ in
                            Circle()
                                .fill(Color("sharkPrimaryLight"))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(height: 10)
                .padding(.top, 2)
            } else {
                Text("")
                    .frame(width: 35, height: 35)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 10)
                    .padding(.top, 2)
            }
        }
        .frame(height: 50)
    }
}

struct NoteEventRow: View {
    var event: Note
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color("sharkPrimaryLight"))
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
}

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date
    @State private var selectedCategory: NoteCategory = .일상
    
    let categories: [NoteCategory] = NoteCategory.allCases
    
    init(selectedDate: Date) {
        _date = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("카테고리")) {
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                
                Section(header: Text("날짜 및 시간")) {
                    DatePicker("날짜 및 시간", selection: $date)
                        .datePickerStyle(.compact)
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("일지 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct NoteDetailView: View {
    let event: Note
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color("sharkPrimaryDark"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color("sharkPrimaryLight").opacity(0.3))
                            )
                        
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(event.date.formattedFullKoreanDateString())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color("sharkCardBackground"))
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("상세 내용")
                        .font(.headline)
                    
                    Text(event.description)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                if event.category == .건강 || event.category == .발달 {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("성장 차트")
                            .font(.headline)
                        
                        HStack {
                            Rectangle()
                                .fill(Color("sharkPrimaryLight").opacity(0.5))
                                .frame(height: 150)
                                .overlay(
                                    Text("성장 차트 영역")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("관련 기록")
                        .font(.headline)
                    
                    ForEach(1...2, id: \.self) { _ in
                        HStack {
                            Circle()
                                .fill(Color("sharkPrimaryLight"))
                                .frame(width: 8, height: 8)
                            
                            Text("관련 기록 항목")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("날짜")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("sharkCardBackground"))
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("일지 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
                        Label("수정", systemImage: "pencil")
                    }
                    
                    Button(action: {}) {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoteView()
    }
}
