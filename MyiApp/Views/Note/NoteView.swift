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
    @State private var isLoading = false
    @State private var showMonthYearPicker = false
    
    // 선택된 날짜 초기값을 nil로 설정하고 onAppear에서 오늘 날짜로 설정
    @State private var selectedDate: Date? = nil
    
    var body: some View {
        ScrollView {
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
                    .padding(.bottom, 10)
                
                // 카테고리 필터
                categoryFilterSection
                
                Divider()
                    .padding(.horizontal)
                
                // 선택된 날짜의 이벤트 목록
                selectedDateEventsSection
                
                // 하단 여백 추가
                Spacer(minLength: 60)
            }
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
            
            // 화면이 나타날 때마다 오늘 날짜 선택
            selectToday()
            
            // 초기 데이터 로드 완료 후 로딩 인디케이터 숨기기
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
            }
        }
    }
    
    // 오늘 날짜 선택 함수
    private func selectToday() {
        let today = Date()
        selectedDate = today
        
        // 선택된 월이 오늘이 속한 월이 아니면 오늘이 속한 월로 변경
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: viewModel.selectedMonth)
        let todayMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: viewModel.selectedMonth)
        let todayYear = calendar.component(.year, from: today)
        
        if currentMonth != todayMonth || currentYear != todayYear {
            viewModel.selectedMonth = today
            viewModel.fetchCalendarDays()
        }
        
        // 캘린더 데이터가 로드된 후 오늘 날짜 선택
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
                            .font(.title2)
                            .fontWeight(.bold)
                        
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
                
                // 이전/다음 달 버튼 그룹화
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
                .padding(.leading, 8) // 좌측 여백 추가
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
                        // 이벤트 목록 표시
                        VStack(spacing: 12) {
                            ForEach(filteredEvents) { event in
                                NoteEventRow(event: event) {
                                    selectedEvent = event
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
            } else {
                emptyEventsView
            }
        }
    }
    
    // 이벤트가 없거나 날짜가 선택되지 않았을 때 표시할 뷰
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
        .padding(.vertical, 20)
    }
}

// 일지 이벤트 행 컴포넌트 수정
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

#Preview {
    NavigationStack {
        NoteView()
    }
}
