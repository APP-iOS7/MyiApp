//
//  NoteView.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/13/25.
//

import SwiftUI

struct NoteView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingNoteEditor = false
    @State private var selectedFilterCategory: NoteCategory? = nil
    @State private var selectedEvent: Note? = nil
    @State private var showMonthYearPicker = false
    @State private var selectedDate: Date? = nil
    @State private var isFirstAppear = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let babyInfo = viewModel.babyInfo {
                    BabyBirthdayInfoView(babyName: babyInfo.name, birthDate: babyInfo.birthDate)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                } else {
                    Text("아기 정보를 불러오는 중...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                }
                
                // 캘린더 헤더
                calendarHeaderSection
                // 캘린더 그리드
                calendarGridSection
                    .padding(.bottom, 10)
                // 카테고리 필터
                categoryFilterSection
                
                Divider()
                    .padding(.horizontal)
                
                // 선택된 날짜의 이벤트 목록
                selectedDateEventsSection

                Spacer(minLength: 60)
            }
        }
        .navigationTitle("육아 수첩")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNoteEditor, onDismiss: {
            if viewModel.toastMessage != nil {
            }
        }) {
            NoteEditorView(selectedDate: viewModel.selectedDay?.date ?? Date())
                .environmentObject(viewModel)
        }
        .navigationDestination(item: $selectedEvent) { event in
            NoteDetailView(event: event)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showMonthYearPicker) {
            VStack {
                HStack {
                    Button("취소") {
                        showMonthYearPicker = false
                    }
                    Spacer()
                    Button("확인") {
                        showMonthYearPicker = false
                    }
                }
                .padding()
                
                DatePicker("", selection: $viewModel.selectedMonth, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .onChange(of: viewModel.selectedMonth) {
                        viewModel.fetchCalendarDays()
                    }
                    .padding()
            }
        }
        .onAppear {
            if isFirstAppear {
                selectToday()
                isFirstAppear = false
            }
        }
        .toast(message: $viewModel.toastMessage)
    }
    
    // 오늘 날짜 선택
    private func selectToday() {
        let today = Date()
        selectedDate = today
        
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: viewModel.selectedMonth)
        let todayMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: viewModel.selectedMonth)
        let todayYear = calendar.component(.year, from: today)
        
        if currentMonth != todayMonth || currentYear != todayYear {
            viewModel.selectedMonth = today
            viewModel.fetchCalendarDays()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let todayDay = viewModel.days.first(where: { $0.isToday }) {
                viewModel.selectedDay = todayDay
            }
        }
    }
    
    // MARK: - 캘린더 헤더 섹션
    private var calendarHeaderSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    showMonthYearPicker = true
                }) {
                    HStack {
                        Text(viewModel.currentMonth)
                            .font(.custom("Cafe24-Ohsquareair", size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    selectToday()
                }) {
                    Text("오늘")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(.white)
                        .background(Capsule().fill(Color("sharkPrimaryColor")))
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.changeMonth(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        viewModel.changeMonth(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.leading, 8)
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
    }
    
    // MARK: - 캘린더 그리드
    private var calendarGridSection: some View {
        let days = viewModel.days
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days) { day in
                CalendarDayView(
                    day: day,
                    selectedDate: $selectedDate,
                    events: viewModel.getEventsForDay(day),
                    isBirthday: viewModel.isBirthday(day.date)
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
    }
    
    // MARK: - 카테고리 필터
    private var categoryFilterSection: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button("모든 알림 삭제") {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        print("모든 알림이 삭제되었습니다")
                    }
                    Button(action: {
                        selectedFilterCategory = nil
                    }) {
                        Text("전체")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
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
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
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
    }
    
    // MARK: - 선택된 날짜의 이벤트
    private var selectedDateEventsSection: some View {
        VStack(alignment: .leading) {
            if let selectedDay = viewModel.selectedDay, let date = selectedDay.date {
                HStack {
                    Text("\(date.formattedFullKoreanDateString())")
                        .font(.headline)
                    
                    if viewModel.isBirthday(date) {
                        Text("🎂 생일")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.pink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.pink.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingNoteEditor = true
                    }) {
                        Label("일지/일정 추가", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(Color("sharkPrimaryDark"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                let dayEvents = viewModel.events[Calendar.current.startOfDay(for: date)] ?? []
                
                if dayEvents.isEmpty {
                    emptyEventsView
                } else {
                    let filteredEvents = selectedFilterCategory == nil ?
                    dayEvents :
                    dayEvents.filter { $0.category == selectedFilterCategory }
                    
                    if filteredEvents.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("sharkPrimaryLight"))
                                .padding(.top, 20)
                            
                            Text("해당 카테고리의 기록이 없습니다.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                        .frame(height: 150)
                        .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(filteredEvents) { event in
                                NoteEventRow(event: event) {
                                    selectedEvent = event
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
            } else {
                emptyEventsView
            }
        }
    }
    
    private var emptyEventsView: some View {
        VStack {
            Image(systemName: "note.text")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(Color("sharkPrimaryLight"))
                .padding(.top, 20)
            
            Text("기록된 일지가 없습니다.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }
}

struct NoteEventRow: View {
    var event: Note
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 12) {
                if event.category == .일지 && !event.imageURLs.isEmpty {
                    CustomAsyncImageView(imageUrlString: event.imageURLs[0])
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(categoryColor(for: event.category).opacity(0.3), lineWidth: 2)
                        )
                } else {
                    Image(systemName: categoryIcon(for: event.category))
                        .foregroundColor(categoryColor(for: event.category))
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(categoryColor(for: event.category).opacity(0.2))
                        )
                }
                
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
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if event.category == .일지 && event.imageURLs.count > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.system(size: 10))
                            Text("\(event.imageURLs.count)")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
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
        case .일지:
            return Color("sharkPrimaryColor")
        case .일정:
            return Color.orange
        }
    }
    
    private func categoryIcon(for category: NoteCategory) -> String {
        switch category {
        case .일지:
            return "note.text"
        case .일정:
            return "calendar"
        }
    }
}
