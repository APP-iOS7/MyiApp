//
//  NoteViewModel.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/20/25.
//

import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseStorage
import UIKit

@MainActor
class NoteViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    private let databaseService = DatabaseService.shared
    private let caregiverManager = CaregiverManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var babyInfo: Baby?
    
    @Published var selectedMonth: Date = Date()
    @Published var days: [CalendarDay] = []
    @Published var weekdays: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    @Published var selectedDay: CalendarDay?
    
    @Published var events: [Date: [Note]] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var toastMessage: ToastMessage?
    
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
        
        caregiverManager.$notes
            .receive(on: RunLoop.main)
            .sink { [weak self] notes in
                self?.processNotes(notes)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 노트 데이터 처리
    private func processNotes(_ notes: [Note]) {
        var newEvents: [Date: [Note]] = [:]
        let calendar = Calendar.current
        
        for note in notes {
            let startOfDay = calendar.startOfDay(for: note.date)
            if var dayNotes = newEvents[startOfDay] {
                dayNotes.append(note)
                dayNotes.sort { $0.date < $1.date }
                newEvents[startOfDay] = dayNotes
            } else {
                newEvents[startOfDay] = [note]
            }
        }
        
        self.events = newEvents
        self.isLoading = false
    }
    
    // MARK: - 아기 정보 가져오기
    private func fetchBabyInfo() {
        self.babyInfo = caregiverManager.selectedBaby
    }
    
    // MARK: - 노트 추가
    func addNote(note: Note) {
        guard let baby = babyInfo else { return }
        
        isLoading = true
        
        let docRef = db.collection("babies").document(baby.id.uuidString)
            .collection("notes")
            .document(note.id.uuidString)
        
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(note)
            
            docRef.setData(data) { [weak self] error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if error != nil {
                        self.errorMessage = "노트 추가 실패"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "노트 인코딩 실패"
            }
        }
    }
    
    // MARK: - 노트 업데이트
    func updateNote(note: Note) {
        guard let baby = babyInfo else { return }
        
        isLoading = true
        
        let docRef = db.collection("babies").document(baby.id.uuidString)
            .collection("notes")
            .document(note.id.uuidString)
        
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(note)
            
            docRef.setData(data, merge: true) { [weak self] error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if error != nil {
                        self.errorMessage = "노트 업데이트 실패"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "노트 인코딩 실패"
            }
        }
    }
    
    // MARK: - 노트 삭제
    func deleteNote(note: Note) {
        cancelNotificationForNote(note)
        
        guard let baby = babyInfo else { return }
        
        isLoading = true
        
        db.collection("babies").document(baby.id.uuidString)
            .collection("notes")
            .document(note.id.uuidString)
            .delete { [weak self] error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if error != nil {
                        self.errorMessage = "노트 삭제 실패"
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
            for day in 1..<firstWeekday {
                if let prevDate = calendar.date(byAdding: .day, value: -(firstWeekday - day), to: startDate) {
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
            
            _ = Calendar.current.dateComponents([.year, .month], from: newMonth)
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
    
    // MARK: - 유틸리티 메서드
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
    
    // MARK: - 리프레시
    func refreshData() {
        fetchBabyInfo()
        selectToday()
    }
    
    // MARK: - ID로 노트 찾기
    func getNoteById(_ id: UUID) -> Note? {
        for (_, notes) in events {
            if let note = notes.first(where: { $0.id == id }) {
                return note
            }
        }
        return nil
    }

    // MARK: - 알림 정보 업데이트
    func updateNoteNotification(noteId: UUID, enabled: Bool, time: Date?) {
        guard let note = getNoteById(noteId) else { return }
        
        let updatedNote = Note(
            id: noteId,
            title: note.title,
            description: note.description,
            date: note.date,
            category: note.category,
            imageURLs: note.imageURLs,
            notificationEnabled: enabled,
            notificationTime: time
        )
        
        updateNote(note: updatedNote)
    }
}

// MARK: - 이미지 관련 확장
extension NoteViewModel {
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
            return
        }
        
        guard authService.user != nil, let babyId = babyInfo?.id else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "인증 정보가 없음"])))
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("images/\(babyId.uuidString)/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error ?? NSError(domain: "UploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "업로드 실패"])))
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error ?? NSError(domain: "URLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL 가져오기 실패"])))
                    return
                }
                
                completion(.success(url.absoluteString))
            }
        }
    }
    
    // 여러 이미지 업로드
    func uploadImages(_ images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        var uploadedURLs: [String] = []
        let group = DispatchGroup()
        
        for image in images {
            group.enter()
            
            uploadImage(image) { result in
                switch result {
                case .success(let url):
                    uploadedURLs.append(url)
                case .failure(_):
                    print("이미지 업로드 실패")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !uploadedURLs.isEmpty {
                completion(.success(uploadedURLs))
            } else if !images.isEmpty {
                completion(.failure(NSError(domain: "UploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "이미지 업로드 실패"])))
            } else {
                completion(.success([]))
            }
        }
    }
    
    // 이미지가 있는 노트 추가
    func addNoteWithImages(note: Note, images: [UIImage]) {
        self.isLoading = true
        
        uploadImages(images) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let imageURLs):
                    // 이미지 URL과 함께 노트 추가
                    var updatedNote = note
                    updatedNote.imageURLs = imageURLs
                    self.addNote(note: updatedNote)
                    
                    if note.category == .일지 {
                        self.toastMessage = ToastMessage(message: "이미지와 함께 새 일지가 저장되었습니다.", type: .success)
                    } else {
                        self.toastMessage = ToastMessage(message: "새 일정이 저장되었습니다.", type: .success)
                    }
                    
                case .failure(let error):
                    // 이미지 업로드 실패 처리
                    self.errorMessage = "이미지 업로드 실패: \(error.localizedDescription)"
                    // 이미지 없이 노트만 추가
                    self.addNote(note: note)
                    self.toastMessage = ToastMessage(message: "이미지 업로드 실패, 내용은 저장되었습니다.", type: .error)
                }
            }
        }
    }
    
    // 기존 노트에 이미지 추가 및 업데이트
    func updateNoteWithImages(note: Note, newImages: [UIImage]) {
        isLoading = true
        
        uploadImages(newImages) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let newImageURLs):
                    var updatedNote = note
                    updatedNote.imageURLs.append(contentsOf: newImageURLs)
                    
                    self.updateNote(note: updatedNote)
                    
                    if note.category == .일지 {
                        self.toastMessage = ToastMessage(message: "일지가 수정되었습니다.", type: .success)
                    } else {
                        self.toastMessage = ToastMessage(message: "일정이 수정되었습니다.", type: .success)
                    }
                    
                case .failure(let error):
                    self.errorMessage = "이미지 업로드 실패: \(error.localizedDescription)"
                    self.updateNote(note: note)
                    self.toastMessage = ToastMessage(message: "이미지 업로드 실패, 내용은 수정되었습니다.", type: .error)
                }
            }
        }
    }
    
    // 이미지 삭제
    func deleteImage(fromNote note: Note, at index: Int) {
        guard index < note.imageURLs.count else { return }
        
        var updatedNote = note
        let imageToDelete = note.imageURLs[index]
        updatedNote.imageURLs.remove(at: index)
        
        updateNote(note: updatedNote)
        
        if let url = URL(string: imageToDelete), let path = url.path.components(separatedBy: "o/").last?.removingPercentEncoding?.components(separatedBy: "?").first {
            let storageRef = Storage.storage().reference().child(path)
            storageRef.delete { error in
                if error != nil {
                    print("Firebase Storage에서 이미지 삭제 실패")
                }
            }
        }
    }
}

// MARK: - 알림 관련 확장
extension NoteViewModel {
    func scheduleNotificationForNote(_ note: Note, minutesBefore: Int) -> Bool {
        guard note.category == .일정 else { return false }
        
        if NotificationService.shared.authorizationStatus == .authorized {
            let notificationResult = NotificationService.shared.scheduleNotification(
                for: note,
                minutesBefore: minutesBefore
            )
            
            if notificationResult.success == false {
                self.toastMessage = ToastMessage(
                    message: notificationResult.message ?? "알림 설정에 실패했습니다.",
                    type: .error
                )
                return false
            }
            return true
        } else {
            self.toastMessage = ToastMessage(
                message: "알림 권한이 필요합니다. 설정에서 권한을 허용해주세요.",
                type: .error
            )
            return false
        }
    }
    
    func cancelNotificationForNote(_ note: Note) {
        if note.category == .일정 {
            NotificationService.shared.cancelNotification(with: note.id.uuidString)
        }
    }
}
