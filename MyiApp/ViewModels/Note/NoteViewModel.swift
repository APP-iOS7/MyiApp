//
//  NoteViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI
import FirebaseFirestore
import Combine

class NoteViewModel: ObservableObject {
    // Firebase 관련 변수
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // 아기 정보 관련 변수
    @Published var babyInfo: Baby?
    
    // 캘린더 관련 변수
    @Published var selectedMonth: Date = Date()
    @Published var days: [CalendarDay] = []
    @Published var weekdays: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    @Published var selectedDay: CalendarDay?
    
    // 노트 관련 변수
    @Published var events: [Date: [Note]] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: selectedMonth)
    }
    
    init() {
        fetchBabyInfo()
        fetchCalendarDays()
        setupListeners()
    }
    
    // MARK: - 아기 정보 가져오기
    private func fetchBabyInfo() {
        // 현재 로그인한 유저의 아기 정보 가져오기
        guard let uid = authService.user?.uid else { return }
        
        db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "아기 정보를 가져오는데 실패했습니다: \(error.localizedDescription)"
                    return
                }
                
                guard let document = snapshot, document.exists,
                      let babyRefs = document.get("babies") as? [DocumentReference],
                      let firstBabyRef = babyRefs.first else {
                    return
                }
                
                // 첫 번째 아기의 정보를 가져옴
                firstBabyRef.getDocument { document, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "아기 상세 정보를 가져오는데 실패했습니다: \(error.localizedDescription)"
                        }
                        return
                    }
                    
                    guard let document = document, document.exists else { return }
                    
                    do {
                        // Firestore 문서를 Baby 모델로 변환
                        let baby = try document.data(as: Baby.self)
                        
                        DispatchQueue.main.async {
                            self.babyInfo = baby
                            // 아기 정보를 가져온 후 노트 데이터를 불러옴
                            self.fetchNotes()
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "아기 정보 변환에 실패했습니다: \(error.localizedDescription)"
                            print("아기 정보 변환 오류: \(error)")
                        }
                    }
                }
            }
    }
    
    // MARK: - 노트 데이터 가져오기
    func fetchNotes() {
        guard let baby = babyInfo else { return }
        
        isLoading = true
        
        // 아기 문서에서 직접 노트 데이터 가져오기
        db.collection("babies").document(baby.id.uuidString)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "노트를 가져오는데 실패했습니다: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let document = snapshot, document.exists else { return }
                    
                    // 'note' 필드에서 노트 배열 가져오기
                    if let notesData = document.data()?["note"] as? [[String: Any]] {
                        // 이벤트 딕셔너리 초기화
                        var newEvents: [Date: [Note]] = [:]
                        
                        let calendar = Calendar.current
                        
                        // 각 노트 데이터를 Note 객체로 변환
                        for noteData in notesData {
                            do {
                                if let note = try self.noteFromDictionary(noteData) {
                                    // 날짜의 시작시간(00:00)을 키로 사용
                                    let startOfDay = calendar.startOfDay(for: note.date)
                                    
                                    // 해당 날짜에 이벤트가 있으면 추가, 없으면 새로운 배열 생성
                                    if var dayNotes = newEvents[startOfDay] {
                                        dayNotes.append(note)
                                        // 시간순으로 정렬
                                        dayNotes.sort { $0.date < $1.date }
                                        newEvents[startOfDay] = dayNotes
                                    } else {
                                        newEvents[startOfDay] = [note]
                                    }
                                }
                            } catch {
                                print("노트 파싱 오류: \(error.localizedDescription)")
                            }
                        }
                        
                        self.events = newEvents
                    } else {
                        // 노트 필드가 없거나 비어 있는 경우 빈 이벤트 딕셔너리 설정
                        self.events = [:]
                    }
                }
            }
    }
    
    // Firestore 딕셔너리에서 Note 객체 생성
    private func noteFromDictionary(_ dict: [String: Any]) throws -> Note? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = dict["title"] as? String,
              let description = dict["description"] as? String,
              let categoryString = dict["category"] as? String,
              let category = NoteCategory(rawValue: categoryString) else {
            return nil
        }
        
        var date: Date
        
        if let timestamp = dict["date"] as? Timestamp {
            date = timestamp.dateValue()
        } else if let dateDouble = dict["date"] as? Double {
            date = Date(timeIntervalSince1970: dateDouble)
        } else {
            return nil
        }
        
        return Note(
            id: id,
            title: title,
            description: description,
            date: date,
            category: category
        )
    }
    
    // Note 객체를 Firestore 딕셔너리로 변환
    private func noteToDictionary(_ note: Note) -> [String: Any] {
        return [
            "id": note.id.uuidString,
            "title": note.title,
            "description": note.description,
            "date": Timestamp(date: note.date),
            "category": note.category.rawValue
        ]
    }
    
    // MARK: - 노트 추가
    func addNote(title: String, description: String, date: Date, category: NoteCategory) {
        guard let baby = babyInfo else { return }
        
        // 새 노트 생성
        let newNote = Note(id: UUID(), title: title, description: description, date: date, category: category)
        
        // Firestore 문서 참조
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        // 트랜잭션으로 노트 배열 업데이트
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 아기 문서 가져오기
            let babyDocument: DocumentSnapshot
            do {
                try babyDocument = transaction.getDocument(babyRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // 기존 노트 배열 가져오기
            var notes: [[String: Any]] = []
            if let existingNotes = babyDocument.data()?["note"] as? [[String: Any]] {
                notes = existingNotes
            }
            
            // 새 노트를 딕셔너리로 변환
            let noteData = self.noteToDictionary(newNote)
            notes.append(noteData)
            
            // 업데이트된 노트 배열로 문서 업데이트
            transaction.updateData(["note": notes], forDocument: babyRef)
            
            return notes
        }) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "노트 추가에 실패했습니다: \(error.localizedDescription)"
                }
                return
            }
            
            // 로컬 상태 업데이트
            DispatchQueue.main.async {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                
                if var dayNotes = self.events[startOfDay] {
                    dayNotes.append(newNote)
                    dayNotes.sort { $0.date < $1.date }
                    self.events[startOfDay] = dayNotes
                } else {
                    self.events[startOfDay] = [newNote]
                }
            }
        }
    }
    
    // MARK: - 노트 업데이트
    func updateNote(note: Note) {
        guard let baby = babyInfo else { return }
        
        // Firestore 문서 참조
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        // 트랜잭션으로 노트 배열 업데이트
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 아기 문서 가져오기
            let babyDocument: DocumentSnapshot
            do {
                try babyDocument = transaction.getDocument(babyRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // 기존 노트 배열 가져오기
            guard var notes = babyDocument.data()?["note"] as? [[String: Any]] else {
                return nil
            }
            
            // 업데이트할 노트 찾기
            if let index = notes.firstIndex(where: { ($0["id"] as? String) == note.id.uuidString }) {
                // 업데이트된 노트로 교체
                let noteData = self.noteToDictionary(note)
                notes[index] = noteData
                
                // 업데이트된 노트 배열로 문서 업데이트
                transaction.updateData(["note": notes], forDocument: babyRef)
            }
            
            return notes
        }) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "노트 업데이트에 실패했습니다: \(error.localizedDescription)"
                }
                return
            }
            
            // 로컬 상태 업데이트
            DispatchQueue.main.async {
                let calendar = Calendar.current
                
                // 기존 이벤트가 있는 날짜에서 제거
                for (day, notes) in self.events {
                    if let index = notes.firstIndex(where: { $0.id == note.id }) {
                        var updatedNotes = notes
                        updatedNotes.remove(at: index)
                        
                        if updatedNotes.isEmpty {
                            self.events.removeValue(forKey: day)
                        } else {
                            self.events[day] = updatedNotes
                        }
                        break
                    }
                }
                
                // 업데이트된 날짜에 추가
                let startOfDay = calendar.startOfDay(for: note.date)
                if var dayNotes = self.events[startOfDay] {
                    dayNotes.append(note)
                    dayNotes.sort { $0.date < $1.date }
                    self.events[startOfDay] = dayNotes
                } else {
                    self.events[startOfDay] = [note]
                }
            }
        }
    }
    
    // MARK: - 노트 삭제
    func deleteNote(note: Note) {
        guard let baby = babyInfo else { return }
        
        // Firestore 문서 참조
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        // 트랜잭션으로 노트 배열 업데이트
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 아기 문서 가져오기
            let babyDocument: DocumentSnapshot
            do {
                try babyDocument = transaction.getDocument(babyRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // 기존 노트 배열 가져오기
            guard var notes = babyDocument.data()?["note"] as? [[String: Any]] else {
                return nil
            }
            
            // 삭제할 노트 찾기
            notes.removeAll { ($0["id"] as? String) == note.id.uuidString }
            
            // 업데이트된 노트 배열로 문서 업데이트
            transaction.updateData(["note": notes], forDocument: babyRef)
            
            return notes
        }) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "노트 삭제에 실패했습니다: \(error.localizedDescription)"
                }
                return
            }
            
            // 로컬 상태 업데이트
            DispatchQueue.main.async {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: note.date)
                
                if var dayNotes = self.events[startOfDay] {
                    dayNotes.removeAll { $0.id == note.id }
                    
                    if dayNotes.isEmpty {
                        self.events.removeValue(forKey: startOfDay)
                    } else {
                        self.events[startOfDay] = dayNotes
                    }
                }
            }
        }
    }
    
    // MARK: - 캘린더 관련 메서드
    func setupListeners() {
        // 아기 정보 변경 감지
        databaseService.$hasBabyInfo
            .sink { [weak self] hasBabyInfo in
                if hasBabyInfo {
                    self?.fetchBabyInfo()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchCalendarDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 선택된 달의 시작 날짜와 마지막 날짜 계산
        let startComponents = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let startDate = calendar.date(from: startComponents) else { return }
        guard let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else { return }
        
        // 해당 월의 첫 번째 요일 계산 (일요일 = 1, 토요일 = 7)
        let firstWeekday = firstWeekdayOfMonth(for: startDate)
        
        // 캘린더에 표시할 날짜 배열 초기화
        var calendarDays: [CalendarDay] = []
        
        // 이전 달의 날짜 추가
        if firstWeekday > 1 {
            for day in (1..<firstWeekday).reversed() {
                if let prevDate = calendar.date(byAdding: .day, value: -day + 1, to: startDate) {
                    let dayNumber = String(calendar.component(.day, from: prevDate))
                    calendarDays.append(CalendarDay(
                        id: UUID(),
                        date: prevDate,
                        dayNumber: dayNumber,
                        isToday: calendar.isDate(prevDate, inSameDayAs: today),
                        isCurrentMonth: false
                    ))
                }
            }
        }
        
        // 현재 달의 날짜 추가
        let daysInMonth = calendar.range(of: .day, in: .month, for: startDate)?.count ?? 0
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startDate) {
                let dayNumber = String(day)
                calendarDays.append(CalendarDay(
                    id: UUID(),
                    date: date,
                    dayNumber: dayNumber,
                    isToday: calendar.isDate(date, inSameDayAs: today),
                    isCurrentMonth: true
                ))
            }
        }
        
        // 다음 달의 날짜 추가 (42일 - 6주 채우기)
        let remainingDays = 42 - calendarDays.count
        for day in 1...remainingDays {
            if let nextDate = calendar.date(byAdding: .day, value: day, to: endDate) {
                let dayNumber = String(calendar.component(.day, from: nextDate))
                calendarDays.append(CalendarDay(
                    id: UUID(),
                    date: nextDate,
                    dayNumber: dayNumber,
                    isToday: calendar.isDate(nextDate, inSameDayAs: today),
                    isCurrentMonth: false
                ))
            }
        }
        
        self.days = calendarDays
        
        // 데이터 불러오기
        fetchNotes()
    }
    
    func firstWeekdayOfMonth(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return 1 }
        return calendar.component(.weekday, from: firstDay)
    }
    
    func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: selectedMonth) {
            selectedMonth = newMonth
            fetchCalendarDays()
            
            // 새로운 달의 1일을 기본으로 선택
            let components = Calendar.current.dateComponents([.year, .month], from: newMonth)
            if let firstDayOfMonth = Calendar.current.date(from: components),
               let firstDay = days.first(where: { $0.isCurrentMonth && Calendar.current.component(.day, from: $0.date!) == 1 }) {
                selectedDay = firstDay
            }
        }
    }
    
    func getEventsForDay(_ day: CalendarDay) -> [Note] {
        guard let date = day.date else { return [] }
        let startOfDay = Calendar.current.startOfDay(for: date)
        return events[startOfDay] ?? []
    }
    
    func isBirthday(_ date: Date?) -> Bool {
        guard let date = date, let birthDate = babyInfo?.birthDate else { return false }
        
        let calendar = Calendar.current
        let birthDay = calendar.component(.day, from: birthDate)
        let birthMonth = calendar.component(.month, from: birthDate)
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        
        return birthDay == day && birthMonth == month
    }
}
