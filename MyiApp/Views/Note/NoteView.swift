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
            // 아기 정보 표시 섹션을 함수로 추출
            babyInfoSection()
            
            // 캘린더 헤더
            calendarHeaderSection()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("sharkCardBackground"))
                )
                .padding(.horizontal)
            
            // 캘린더 그리드
            calendarGridSection()
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            // 카테고리 필터
            categoryFilterSection()
                .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal)
            
            // 선택된 날짜의 이벤트 목록
            selectedDateEventsSection()
            
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
        .onAppear {
            // 앱이 시작될 때 현재 날짜를 선택
            if selectedDate == nil {
                selectedDate = Date()
                if let todayDay = viewModel.days.first(where: { $0.isToday }) {
                    viewModel.selectedDay = todayDay
                }
            }
        }
    }
    
    // MARK: - 아기 정보 섹션
    @ViewBuilder
    private func babyInfoSection() -> some View {
        // 로컬 변수로 babyInfo 가져오기
        let babyInfoValue = viewModel.babyInfo
        
        if let info = babyInfoValue {
            BabyBirthdayInfoView(babyName: info.name, birthDate: info.birthDate)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
    }
    
    // MARK: - 캘린더 헤더 섹션
    @ViewBuilder
    private func calendarHeaderSection() -> some View {
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
    }
    
    // MARK: - 캘린더 그리드 섹션
    @ViewBuilder
    private func calendarGridSection() -> some View {
        let days = viewModel.days
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
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
    }
    
    // MARK: - 카테고리 필터 섹션
    @ViewBuilder
    private func categoryFilterSection() -> some View {
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
    }
    
    // MARK: - 선택된 날짜의 이벤트 섹션
    @ViewBuilder
    private func selectedDateEventsSection() -> some View {
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
                
                if let events = viewModel.events[Calendar.current.startOfDay(for: date)] {
                    NoteEventList(
                        events: events,
                        filteredCategory: selectedFilterCategory
                    ) { event in
                        selectedEvent = event
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("기록된 일지가 없습니다.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
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
    }
}

// MARK: - NoteEditorView
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

// MARK: - NoteDetailView
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
