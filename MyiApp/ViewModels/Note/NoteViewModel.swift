//
//  NoteViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class NoteViewModel: ObservableObject {
    @Published var days: [CalendarDay] = []
    @Published var currentMonth = ""
    @Published var selectedMonth: Date = Date()
    @Published var selectedDay: CalendarDay?
    @Published var events: [Date: [Note]] = [:]
    @Published var babyInfo: BabyInfo?
    
    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    init() {
        fetchCalendarDays()
        loadMockEvents()
        fetchBabyInfo() // 아기 정보 가져오기
    }
    
    // MARK: - 캘린더 관련 메서드
    
    func fetchCalendarDays() {
        days = getCalendarDays()
        updateMonthTitle()
    }
    
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newDate
            fetchCalendarDays()
        }
    }
    
    func updateMonthTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        currentMonth = formatter.string(from: selectedMonth)
    }
    
    func getCalendarDays() -> [CalendarDay] {
        var days: [CalendarDay] = []
        let calendar = Calendar.current
        
        // 현재 선택된 월의 첫날과 마지막 날
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // 첫날의 요일 (일요일 = 1, 토요일 = 7)
        let firstDayOfWeek = calendar.component(.weekday, from: startOfMonth)
        
        // 이전 월의 날짜 추가 (수정된 부분)
        if firstDayOfWeek > 1 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
            let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            
            // 표시할 이전 달의 시작일을 계산
            let startDay = daysInPreviousMonth - (firstDayOfWeek - 2)
            
            for i in startDay...daysInPreviousMonth {
                // 이전 달의 해당 날짜를 직접 계산
                if let date = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: previousMonth)
                ) {
                    // 이전 달의 1일부터 i일 만큼 더해줌
                    if let exactDate = calendar.date(byAdding: .day, value: i - 1, to: date) {
                        days.append(CalendarDay(
                            id: UUID(),
                            date: exactDate,
                            dayNumber: "\(i)",
                            isToday: calendar.isDateInToday(exactDate),
                            isCurrentMonth: false
                        ))
                    }
                }
            }
        }
        
        // 현재 월의 날짜 추가
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
        let today = calendar.startOfDay(for: Date())
        
        for i in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: i - 1, to: startOfMonth) {
                let isToday = calendar.isDate(date, inSameDayAs: today)
                days.append(CalendarDay(id: UUID(), date: date, dayNumber: "\(i)", isToday: isToday, isCurrentMonth: true))
            }
        }
        
        // 다음 월의 날짜 추가
        let remainingDays = 42 - days.count // 6주 표시를 위해
        if remainingDays > 0 {
            for i in 1...remainingDays {
                if let date = calendar.date(byAdding: .day, value: i, to: endOfMonth) {
                    days.append(CalendarDay(id: UUID(), date: date, dayNumber: "\(i)", isToday: false, isCurrentMonth: false))
                }
            }
        }
        
        return days
    }
    
    // MARK: - 이벤트 관련 메서드
    
    func getEventsForDay(_ day: CalendarDay) -> [Note] {
        guard let date = day.date else { return [] }
        let startOfDay = Calendar.current.startOfDay(for: date)
        return events[startOfDay] ?? []
    }
    
    func addEvent(_ event: Note) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: event.date)
        
        if var dayEvents = events[startOfDay] {
            dayEvents.append(event)
            events[startOfDay] = dayEvents
        } else {
            events[startOfDay] = [event]
        }
        
        objectWillChange.send()
    }
    
    private func loadMockEvents() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        events = [
            today: [
                Note(
                    id: UUID(),
                    title: "체중 측정",
                    description: "오늘 몸무게: 8.2kg, 전주 대비 +200g 증가",
                    date: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: today)!,
                    category: .건강
                ),
                Note(
                    id: UUID(),
                    title: "첫 이유식",
                    description: "쌀미음을 처음으로 먹였더니 잘 먹음. 약 20ml 정도 섭취함.",
                    date: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!,
                    category: .식사
                )
            ],
            yesterday: [
                Note(
                    id: UUID(),
                    title: "예방접종",
                    description: "BCG 접종 완료. 특별한 이상반응 없음.",
                    date: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: yesterday)!,
                    category: .건강
                )
            ],
            tomorrow: [
                Note(
                    id: UUID(),
                    title: "소아과 방문 예정",
                    description: "정기 검진 및 성장 발달 확인",
                    date: calendar.date(bySettingHour: 13, minute: 30, second: 0, of: tomorrow)!,
                    category: .건강
                )
            ]
        ]
        
        // 특별 이벤트 추가 (테스트용)
        let specialDay = calendar.date(byAdding: .day, value: 5, to: today)!
        events[calendar.startOfDay(for: specialDay)] = [
            Note(
                id: UUID(),
                title: "첫 걸음마",
                description: "오늘 아기가 처음으로 3걸음을 혼자 걸었어요!",
                date: calendar.date(bySettingHour: 15, minute: 20, second: 0, of: specialDay)!,
                category: .발달
            ),
            Note(
                id: UUID(),
                title: "이유식 시작",
                description: "오늘부터 계란노른자를 추가한 이유식을 시작했어요.",
                date: calendar.date(bySettingHour: 12, minute: 0, second: 0, of: specialDay)!,
                category: .식사
            ),
            Note(
                id: UUID(),
                title: "공원 나들이",
                description: "오후에 동네 공원에 가서 30분 정도 산책했어요. 날씨가 좋아서 기분이 좋았어요.",
                date: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: specialDay)!,
                category: .일상
            )
        ]
        
        // 일정이 많은 날 테스트
        let busyDay = calendar.date(byAdding: .day, value: 3, to: today)!
        var busyDayEvents: [Note] = []
        
        for i in 0..<5 {
            busyDayEvents.append(Note(
                id: UUID(),
                title: "일정 #\(i+1)",
                description: "테스트용 일정입니다.",
                date: calendar.date(bySettingHour: 8 + i, minute: 0, second: 0, of: busyDay)!,
                category: NoteCategory.allCases[i % NoteCategory.allCases.count]
            ))
        }
        
        events[calendar.startOfDay(for: busyDay)] = busyDayEvents
        
        // 추가 더미 이벤트 생성
        for i in 2...15 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                let startOfDay = calendar.startOfDay(for: date)
                if i % 3 == 0 && events[startOfDay] == nil {
                    events[startOfDay] = [
                        Note(
                            id: UUID(),
                            title: "성장 기록",
                            description: "키: 62cm, 몸무게: 8.4kg",
                            date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!,
                            category: .발달
                        )
                    ]
                }
            }
        }
    }
    
    // MARK: - 아기 정보 관련 메서드
    
    func fetchBabyInfo() {
        // 임시 데이터 설정 - 실제로는 Firebase에서 가져와야 함
        // 현재는 하드코딩된 값을 사용
        self.babyInfo = BabyInfo(
            name: "김죠스",
            birthDate: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 19)) ?? Date(),
            gender: .female
        )
        
        // Firebase 연동 후 사용할 코드
        // fetchBabyInfoFromFirebase()
    }
    
    func fetchBabyInfoFromFirebase() {
        // Firebase에서 아기 정보를 가져오는 코드 (예시)
        guard let uid = AuthService.shared.user?.uid else {
            return
        }
        
        Task {
            do {
                // 사용자의 문서 가져오기
                let userDocRef = DatabaseService.shared.db.collection("users").document(uid)
                let userDoc = try await userDocRef.getDocument()
                
                // 사용자에게 연결된 첫 번째 아기 참조 가져오기
                guard let babyRefs = userDoc.get("babies") as? [DocumentReference], !babyRefs.isEmpty else {
                    return
                }
                
                // 첫 번째 아기 정보 가져오기
                let babyRef = babyRefs[0]
                let babyDoc = try await babyRef.getDocument()
                
                // Baby 객체로 변환
                if let babyData = babyDoc.data(),
                   let name = babyData["name"] as? String,
                   let birthDateTimestamp = babyData["birthDate"] as? Timestamp,
                   let genderValue = babyData["gender"] as? Int,
                   let gender = Gender(rawValue: genderValue) {
                    
                    let birthDate = birthDateTimestamp.dateValue()
                    
                    // UI 업데이트는 메인 스레드에서 수행
                    await MainActor.run {
                        self.babyInfo = BabyInfo(
                            name: name,
                            birthDate: birthDate,
                            gender: gender
                        )
                    }
                }
            } catch {
                print("아기 정보 가져오기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 생일 관련 메서드
    
    // 특정 날짜가 아기의 생일인지 확인하는 함수
    func isBirthday(_ date: Date?) -> Bool {
        guard let date = date, let babyInfo = babyInfo else { return false }
        
        let calendar = Calendar.current
        
        // 생일 날짜 컴포넌트 (월과 일만 비교)
        let birthComponents = calendar.dateComponents([.month, .day], from: babyInfo.birthDate)
        let dateComponents = calendar.dateComponents([.month, .day], from: date)
        
        return birthComponents.month == dateComponents.month && birthComponents.day == dateComponents.day
    }
    
    // 매달 아기의 월령 기념일인지 확인하는 함수
    func isMonthlyAnniversary(_ date: Date?) -> Bool {
        guard let date = date, let babyInfo = babyInfo else { return false }
        
        let calendar = Calendar.current
        
        // 생일 날짜 컴포넌트 (일만 비교)
        let birthComponents = calendar.dateComponents([.day], from: babyInfo.birthDate)
        let dateComponents = calendar.dateComponents([.day], from: date)
        
        return birthComponents.day == dateComponents.day
    }
    
    // 특정 날짜의 월령 계산 (해당 날짜 기준 아기가 몇 개월인지)
    func babyAgeInMonths(at date: Date) -> Int {
        guard let babyInfo = babyInfo else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: babyInfo.birthDate, to: date)
        return components.month ?? 0
    }
}

// 노트뷰에서 사용할 간소화된 아기 정보 모델
struct BabyInfo {
    let name: String
    let birthDate: Date
    let gender: Gender
}
