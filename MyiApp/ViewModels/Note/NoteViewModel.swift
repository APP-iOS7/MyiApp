//
//  NoteViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class NoteViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var babyInfo: Baby?
    
    @Published var selectedMonth: Date = Date()
    @Published var days: [CalendarDay] = []
    @Published var weekdays: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    @Published var selectedDay: CalendarDay?
    
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
                
                firstBabyRef.getDocument { document, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "아기 상세 정보를 가져오는데 실패했습니다: \(error.localizedDescription)"
                        }
                        return
                    }
                    
                    guard let document = document, document.exists else { return }
                    
                    do {
                        let baby = try document.data(as: Baby.self)
                        
                        DispatchQueue.main.async {
                            self.babyInfo = baby
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
                    
                    if let notesData = document.data()?["note"] as? [[String: Any]] {
                        var newEvents: [Date: [Note]] = [:]
                        
                        let calendar = Calendar.current
                        
                        for noteData in notesData {
                            do {
                                if let note = try self.noteFromDictionary(noteData) {
                                    let startOfDay = calendar.startOfDay(for: note.date)
                                    
                                    if var dayNotes = newEvents[startOfDay] {
                                        dayNotes.append(note)
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
                        self.events = [:]
                    }
                }
            }
    }
    
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
        
        let newNote = Note(id: UUID(), title: title, description: description, date: date, category: category)
        
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let babyDocument: DocumentSnapshot
            do {
                try babyDocument = transaction.getDocument(babyRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var notes: [[String: Any]] = []
            if let existingNotes = babyDocument.data()?["note"] as? [[String: Any]] {
                notes = existingNotes
            }
            
            let noteData = self.noteToDictionary(newNote)
            notes.append(noteData)
            
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
        
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let babyDocument: DocumentSnapshot
            do {
                try babyDocument = transaction.getDocument(babyRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var notes = babyDocument.data()?["note"] as? [[String: Any]] else {
                return nil
            }
            
            if let index = notes.firstIndex(where: { ($0["id"] as? String) == note.id.uuidString }) {
                let noteData = self.noteToDictionary(note)
                notes[index] = noteData
                
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
            
            DispatchQueue.main.async {
                let calendar = Calendar.current
                
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
        
        let babyRef = db.collection("babies").document(baby.id.uuidString)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let babyDocument: DocumentSnapshot
            do {
                try babyDocument = transaction.getDocument(babyRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var notes = babyDocument.data()?["note"] as? [[String: Any]] else {
                return nil
            }
            
            notes.removeAll { ($0["id"] as? String) == note.id.uuidString }
            
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
            
            DispatchQueue.main.async {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: note.date)
                
                if var dayNotes = self.events[startOfDay] {
                    dayNotes.removeAll { $0.id == note.id }
                    
                    if dayNotes.isEmpty {
                        self.events.removeValue(forKey: startOfDay)
                    } else {
                        dayNotes.sort { $0.date < $1.date }
                        self.events[startOfDay] = dayNotes
                    }
                }
            }
        }
    }
    
    // MARK: - 특정 날짜의 이벤트 가져오기
    func getEventsForDay(_ day: CalendarDay) -> [Note] {
        guard let date = day.date else { return [] }
        let startOfDay = Calendar.current.startOfDay(for: date)
        return (events[startOfDay] ?? []).sorted { $0.date < $1.date }
    }
    
    // MARK: - 캘린더 관련 메서드
    func setupListeners() {
        databaseService.$hasBabyInfo
            .sink { [weak self] hasBabyInfoOptional in
                if let hasBabyInfo = hasBabyInfoOptional, hasBabyInfo {
                    self?.fetchBabyInfo()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchCalendarDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startComponents = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let startDate = calendar.date(from: startComponents) else { return }
        guard let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else { return }
        
        let firstWeekday = firstWeekdayOfMonth(for: startDate)
        
        var calendarDays: [CalendarDay] = []
        
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
            
            let components = Calendar.current.dateComponents([.year, .month], from: newMonth)
            if let firstDay = days.first(where: { $0.isCurrentMonth && Calendar.current.component(.day, from: $0.date!) == 1 }) {
                selectedDay = firstDay
            }
        }
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

extension NoteViewModel {
    func selectToday() {
        selectedMonth = Date()
        
        fetchCalendarDays()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            if let todayDay = self.days.first(where: { $0.isToday }) {
                self.selectedDay = todayDay
            }
        }
    }
    
    // 리프레시
    func refreshData() {
        fetchBabyInfo()
        selectToday()
    }
}
