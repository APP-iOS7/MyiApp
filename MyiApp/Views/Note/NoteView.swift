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
    @State private var selectedDate: Date? = Date()
    @State private var selectedFilterCategory: NoteCategory? = nil
    @State private var selectedEvent: Note? = nil
    @State private var isLoading = false
    @State private var showMonthYearPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 아기 정보 표시 섹션
            if let babyInfo = viewModel.babyInfo {
                BabyBirthdayInfoView(babyName: babyInfo.name, birthDate: babyInfo.birthDate)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            } else {
                // 아기 정보가 없을 때 로딩 인디케이터 또는 안내 메시지
                Text("아기 정보를 불러오는 중...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            }
            
            // 캘린더 헤더
            calendarHeaderSection
            
            // 캘린더 그리드
            calendarGridSection
            
            // 카테고리 필터
            categoryFilterSection
            
            Divider()
                .padding(.horizontal)
            
            // 선택된 날짜의 이벤트 목록
            selectedDateEventsSection
            
            Spacer()
        }
        .navigationTitle("육아 수첩")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // 검색 기능 구현
                    }) {
                        Label("검색", systemImage: "magnifyingglass")
                    }
                    
                    Menu {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedFilterCategory = category
                            }) {
                                HStack {
                                    Text(category.rawValue)
                                    if selectedFilterCategory == category {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            selectedFilterCategory = nil
                        }) {
                            HStack {
                                Text("전체")
                                if selectedFilterCategory == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Label("카테고리 필터", systemImage: "line.3.horizontal.decrease.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(selectedDate: viewModel.selectedDay?.date ?? Date())
                .environmentObject(viewModel)
        }
        .navigationDestination(item: $selectedEvent) { event in
            NoteDetailView(event: event)
                .environmentObject(viewModel)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(width: 80, height: 80)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
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
                    .onChange(of: viewModel.selectedMonth) { _ in
                        viewModel.fetchCalendarDays()
                    }
                    .padding()
            }
        }
        .onAppear {
            isLoading = true
            
            // 앱이 시작될 때 현재 날짜를 선택
            if selectedDate == nil {
                selectedDate = Date()
            }
            
            // 초기 데이터 로드 완료 후 로딩 인디케이터 숨기기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
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
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }
                
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
            
            // 요일 헤더 - 일요일은 빨간색, 토요일은 파란색으로 표시
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
    
    // MARK: - 캘린더 그리드 섹션
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
    
    // MARK: - 카테고리 필터 섹션
    private var categoryFilterSection: some View {
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
    }
    
    // MARK: - 선택된 날짜의 이벤트 섹션
    private var selectedDateEventsSection: some View {
        VStack(alignment: .leading) {
            if let selectedDay = viewModel.selectedDay, let date = selectedDay.date {
                HStack {
                    Text("\(date.formattedFullKoreanDateString())")
                        .font(.headline)
                    
                    // 생일 표시 추가
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
                        Label("추가", systemImage: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(Color("sharkPrimaryDark"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                let dayEvents = viewModel.events[Calendar.current.startOfDay(for: date)] ?? []
                
                if dayEvents.isEmpty {
                    // 이벤트가 없을 때 표시할 뷰
                    emptyEventsView
                } else {
                    // 필터링된 이벤트 목록
                    let filteredEvents = selectedFilterCategory == nil ?
                        dayEvents :
                        dayEvents.filter { $0.category == selectedFilterCategory }
                    
                    if filteredEvents.isEmpty {
                        // 필터링 결과가 없을 때
                        VStack {
                            Spacer()
                            Text("해당 카테고리의 기록이 없습니다.")
                                .foregroundColor(.gray)
                                .padding(.top, 60)
                            Spacer()
                        }
                        .frame(height: 200)
                    } else {
                        // 이벤트 목록 표시
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEvents) { event in
                                    NoteEventRow(event: event) {
                                        selectedEvent = event
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
            } else {
                // 선택된 날짜가 없을 때
                emptyEventsView
            }
        }
    }
    
    // 이벤트가 없거나 날짜가 선택되지 않았을 때 표시할 뷰
    private var emptyEventsView: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "note.text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("sharkPrimaryLight"))
                
                Text("기록된 일지가 없습니다.")
                    .foregroundColor(.gray)
                
                Button(action: {
                    showingNoteEditor = true
                }) {
                    Text("일지 작성하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("sharkPrimaryColor"))
                        )
                }
            }
            .padding(.top, 60)
            Spacer()
        }
        .frame(height: 300)
    }
}

#Preview {
    NavigationStack {
        NoteView()
    }
}
