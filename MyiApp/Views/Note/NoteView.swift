//
//  NoteView.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/13/25.
//

import SwiftUI

struct SafeAreaPaddingView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

struct NoteView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingNoteEditor = false
    @State private var selectedFilterCategory: NoteCategory? = nil
    @State private var selectedEvent: Note? = nil
    @State private var selectedDate: Date? = nil
    @State private var isFirstAppear = true
    
    var body: some View {
        ZStack {
            Color("customBackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                SafeAreaPaddingView()
                    .frame(height: getTopSafeAreaHeight())
                
                ScrollView {
                    VStack(spacing: 0) {
                        if let babyInfo = viewModel.babyInfo {
                            BabyBirthdayInfoView(babyName: babyInfo.name, birthDate: babyInfo.birthDate)
                        } else {
                            Text("아기 정보를 불러오는 중...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                        }
                        
                        VStack(spacing: 0) {
                            // 캘린더 헤더
                            calendarHeaderSection
                            
                            // 캘린더 그리드
                            calendarGridSection
                                .padding(.bottom, 8)
                        }
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 15)
                        
                        // 선택된 날짜 이벤트 섹션
                        VStack(spacing: 0) {
                            if let selectedDay = viewModel.selectedDay, let date = selectedDay.date {
                                VStack(spacing: 12) {
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
                                            Label("추가", systemImage: "plus.circle.fill")
                                                .font(.subheadline)
                                                .foregroundColor(Color("sharkPrimaryDark"))
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                    
                                    // 카테고리 필터
                                    categoryFilterSection
                                        .padding(.top, 4)
                                        .padding(.horizontal)
                                    
                                    // 이벤트 목록
                                    eventsListView(for: date)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                        .padding(.bottom, 16)
                                }
                            } else {
                                emptyEventsView
                                    .padding(.top, 16)
                            }
                        }
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .navigationTitle("육아 수첩")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(selectedDate: viewModel.selectedDay?.date ?? Date())
                .environmentObject(viewModel)
        }
        .navigationDestination(item: $selectedEvent) { event in
            NoteDetailView(event: event)
                .environmentObject(viewModel)
        }
        .onAppear {
            if isFirstAppear {
                selectToday()
                isFirstAppear = false
            }
        }
        .toast(message: $viewModel.toastMessage)
    }
    
    private func getTopSafeAreaHeight() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 0
        }
        
        let height = window.safeAreaInsets.top
        return height * 0.1
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
            ZStack {
                HStack {
                    HStack {
                        Text(viewModel.currentMonth)
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(.button)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.button)
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
                    
                    HStack(spacing: 18) {
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
                }
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedMonth,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(width: 200, height: 30)
                .blendMode(.destinationOver)
                .onChange(of: viewModel.selectedMonth) {
                    viewModel.fetchCalendarDays()
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
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
            .padding(.top, 4)
        }
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: {
                    selectedFilterCategory = nil
                }) {
                    Text("전체")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
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
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedFilterCategory == category ? Color("sharkPrimaryColor") : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedFilterCategory == category ? .white : .primary)
                    }
                }
            }
        }
    }
    
    // MARK: - 날짜별 이벤트 목록 뷰
    private func eventsListView(for date: Date) -> some View {
        let dayEvents = viewModel.events[Calendar.current.startOfDay(for: date)] ?? []
        
        if dayEvents.isEmpty {
            return AnyView(emptyEventsView)
        } else {
            let filteredEvents = selectedFilterCategory == nil ?
            dayEvents :
            dayEvents.filter { $0.category == selectedFilterCategory }
            
            if filteredEvents.isEmpty {
                return AnyView(
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
                        .padding(.vertical, 12)
                )
            } else {
                return AnyView(
                    VStack(spacing: 10) {
                        ForEach(filteredEvents, id: \.id) { event in
                            NoteEventRow(event: event) {
                                selectedEvent = event
                            }
                            .environmentObject(viewModel)
                            .id(event.id)
                        }
                    }
                )
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
                .padding(.top, 4)
            
            Text("기록된 일지가 없습니다.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 97)
        .padding(.vertical, 8)
    }
}
