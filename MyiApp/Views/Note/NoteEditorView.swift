//
//  NoteEditorView.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/13/25.
//

import SwiftUI
import PhotosUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: NoteViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date
    @State private var selectedCategory: NoteCategory = .일지
    @State private var selectedImages: [UIImage] = []
    @State private var showingPhotoPicker = false
    @State private var existingImageURLs: [String] = []
    @State private var isSaving = false
    
    // 알림 관련 상태 변수
    @State private var isReminderEnabled: Bool = false
    @State private var reminderTime: Date
    @State private var reminderMinutesBefore: Int = 30
    @State private var showAlertMessage = false
    @State private var alertMessage = ""
    
    let isEditing: Bool
    let noteId: UUID?
    
    init(selectedDate: Date, note: Note? = nil) {
        // 날짜 초기화 - 현재 시간보다 30분 후로 기본 설정
        let futureDate = max(selectedDate, Date().addingTimeInterval(30 * 60))
        _date = State(initialValue: futureDate)
        
        // 알림 시간은 일정 시간 30분 전으로 설정 (최소한 현재 시간 이후)
        let defaultReminderTime = futureDate.addingTimeInterval(-30 * 60)
        _reminderTime = State(initialValue: max(defaultReminderTime, Date().addingTimeInterval(60)))
        
        if let note = note {
            _title = State(initialValue: note.title)
            _description = State(initialValue: note.description)
            _date = State(initialValue: note.date)
            _selectedCategory = State(initialValue: note.category)
            _existingImageURLs = State(initialValue: note.imageURLs)
            
            // 알림 정보가 있으면 설정
            if let notificationEnabled = note.notificationEnabled,
               notificationEnabled,
               let notificationTime = note.notificationTime {
                _isReminderEnabled = State(initialValue: true)
                _reminderTime = State(initialValue: notificationTime)
                
                // 시간 차이 계산
                let diffMinutes = Int(note.date.timeIntervalSince(notificationTime) / 60)
                if diffMinutes > 0 {
                    _reminderMinutesBefore = State(initialValue: diffMinutes)
                }
            }
            
            self.isEditing = true
            self.noteId = note.id
        } else {
            self.isEditing = false
            self.noteId = nil
        }
    }
    
    private func checkNotificationStatus() {
        guard let id = noteId, selectedCategory == .일정 else { return }
        
        print("🔔 알림 상태 확인: \(id.uuidString)")
        // 모든 알림 출력 (디버깅)
        NotificationService.shared.printAllScheduledNotifications()
        
        // 먼저 Note 객체의 저장된 알림 상태 확인
        if let note = viewModel.getNoteById(id),
           let enabled = note.notificationEnabled,
           enabled,
           let notificationTime = note.notificationTime {
            
            isReminderEnabled = true
            reminderTime = notificationTime
            
            // 시간 차이 계산
            let diffMinutes = Int(date.timeIntervalSince(notificationTime) / 60)
            if diffMinutes > 0 {
                reminderMinutesBefore = diffMinutes
            }
            
            print("🔔 Note 객체에서 알림 정보 로드: time=\(notificationTime), \(reminderMinutesBefore)분 전")
            return
        }
        
        // 실제 알림 시스템에서 확인
        NotificationService.shared.findNotificationForNote(noteId: id.uuidString) { exists, triggerDate, _ in
            print("🔔 알림 시스템 확인 결과: 존재=\(exists), 시간=\(String(describing: triggerDate))")
            
            DispatchQueue.main.async {
                self.isReminderEnabled = exists
                
                if exists, let triggerDate = triggerDate {
                    self.reminderTime = triggerDate
                    
                    // 시간 차이 계산
                    let diffMinutes = Int(self.date.timeIntervalSince(triggerDate) / 60)
                    
                    if diffMinutes > 0 {
                        if [10, 15, 30, 60, 120, 1440].contains(diffMinutes) {
                            self.reminderMinutesBefore = diffMinutes
                        } else {
                            self.reminderMinutesBefore = diffMinutes
                        }
                    } else {
                        self.reminderMinutesBefore = 30 // 기본값
                    }
                    
                    // Note 객체에 알림 정보 업데이트
                    if let id = self.noteId {
                        self.viewModel.updateNoteNotification(
                            noteId: id,
                            enabled: true,
                            time: triggerDate
                        )
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("카테고리")) {
                    VStack(spacing: 8) {
                        RadioButtonRow(
                            title: "일지",
                            icon: "note.text",
                            color: Color("sharkPrimaryColor"),
                            isSelected: selectedCategory == .일지
                        ) {
                            selectedCategory = .일지
                        }
                        
                        RadioButtonRow(
                            title: "일정",
                            icon: "calendar",
                            color: Color.orange,
                            isSelected: selectedCategory == .일정
                        ) {
                            selectedCategory = .일정
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                
                Section(header: Text("날짜 및 시간")) {
                    DatePicker("날짜 및 시간", selection: $date)
                        .datePickerStyle(.compact)
                        .onChange(of: date) { _, newValue in
                            if isReminderEnabled {
                                reminderTime = newValue.addingTimeInterval(TimeInterval(-reminderMinutesBefore * 60))
                                
                                if reminderTime < Date() {
                                    let possibleTime = Date().addingTimeInterval(5 * 60)
                                    if possibleTime < newValue {
                                        reminderTime = possibleTime
                                        let diffMinutes = Int(newValue.timeIntervalSince(possibleTime) / 60)
                                        reminderMinutesBefore = diffMinutes
                                    } else {
                                        isReminderEnabled = false
                                        showAlertMessage = true
                                        alertMessage = "일정 시간이 너무 가까워 알림을 설정할 수 없습니다."
                                    }
                                }
                            }
                        }
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                }
                
                if selectedCategory == .일지 {
                    Section(header: Text("이미지")) {
                        if !existingImageURLs.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("기존 이미지")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                URLImagePreviewGrid(imageURLs: existingImageURLs) { index in
                                    if let id = noteId, let note = viewModel.events.values.flatMap({ $0 }).first(where: { $0.id == id }) {
                                        viewModel.deleteImage(fromNote: note, at: index)
                                        existingImageURLs.remove(at: index)
                                    }
                                }
                            }
                        }
                        
                        if !selectedImages.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("추가할 이미지")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                ImagePreviewGrid(images: $selectedImages) { index in
                                    selectedImages.remove(at: index)
                                }
                            }
                        }
                        
                        Button(action: {
                            showingPhotoPicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("이미지 추가")
                            }
                        }
                        .sheet(isPresented: $showingPhotoPicker) {
                            PhotoPicker(selectedImages: $selectedImages, selectionLimit: 10)
                        }
                    }
                }
                
                if selectedCategory == .일정 {
                    Section(header: Text("알림")) {
                        NoteReminderView(
                            isEnabled: $isReminderEnabled,
                            reminderTime: $reminderTime,
                            reminderMinutesBefore: $reminderMinutesBefore,
                            eventDate: date
                        )
                    }
                }
            }
            .navigationTitle(isEditing ? "내용 수정" : "새 \(selectedCategory.rawValue) 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "수정" : "저장") {
                        saveNote()
                    }
                    .disabled(title.isEmpty || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            CleanLoadingOverlay(
                                message: isEditing ? "수정 중..." : "저장 중...",
                                imageNames: ["sharkNewBorn", "sharkInfant", "sharkToddler"],
                                frameInterval: 0.5
                            )
                        )
                }
            }
            .alert("알림", isPresented: $showAlertMessage) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                print("🔔 NoteEditorView appeared for \(isEditing ? "editing" : "new") \(selectedCategory.rawValue)")
                checkNotificationStatus()
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty { return }
        
        isSaving = true
        print("노트 저장 시작: \(selectedCategory.rawValue)")
        
        let noteId = self.noteId ?? UUID()
        print("노트 ID: \(noteId.uuidString)")
        
        var notificationEnabled: Bool? = nil
        var notificationTime: Date? = nil
        
        if selectedCategory == .일정 {
            if isReminderEnabled {
                let result = handleNotificationForEvent(noteId: noteId)
                
                if result.success, let time = result.time {
                    notificationEnabled = true
                    notificationTime = time
                } else {
                    notificationEnabled = false
                    
                    if !result.success {
                        alertMessage = result.message ?? "알림 설정에 실패했습니다."
                        showAlertMessage = true
                    }
                }
            } else {
                notificationEnabled = false
                if isEditing {
                    NotificationService.shared.cancelNotification(with: noteId.uuidString)
                }
            }
        }
        
        // 2. 기본 Note 객체 생성
        let note = Note(
            id: noteId,
            title: title,
            description: description,
            date: date,
            category: selectedCategory,
            imageURLs: existingImageURLs,
            notificationEnabled: notificationEnabled,
            notificationTime: notificationTime
        )
        
        // 3. 노트 저장 처리 (이미지 유무에 따라)
        if !selectedImages.isEmpty && selectedCategory == .일지 {
            // 이미지가 있는 노트
            if isEditing {
                viewModel.updateNoteWithImages(note: note, newImages: selectedImages)
            } else {
                viewModel.addNoteWithImages(note: note, images: selectedImages)
            }
            
            // 이미지 업로드는 비동기 처리되므로 콜백에서 화면 닫기
            print("이미지 저장 처리 중...")
        } else {
            if isEditing {
                viewModel.updateNote(note: note)
            } else {
                viewModel.addNote(note: note)
            }
            
            setSuccessToastMessage(withNotification: notificationEnabled == true)
            
            print("노트 저장 완료 - 화면 닫기")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSaving = false
                dismiss()
            }
        }
    }
    
    private func handleNotificationForEvent(noteId: UUID) -> (success: Bool, time: Date?, message: String?) {
        print("알림 처리: isEnabled=\(isReminderEnabled), noteId=\(noteId)")
        
        if reminderTime <= Date() {
            print("알림 시간이 현재보다 이전: \(reminderTime)")
            return (false, nil, "알림 시간은 현재 시간 이후여야 합니다.")
        }
        
        let timeDiff = max(1, Int(date.timeIntervalSince(reminderTime) / 60))
        
        let note = Note(
            id: noteId,
            title: title,
            description: description,
            date: date,
            category: .일정
        )
        
        let result = NotificationService.shared.scheduleNotification(
            for: note,
            minutesBefore: timeDiff
        )
        
        print("알림 예약 결과: \(result)")
        return result
    }
    
    private func setSuccessToastMessage(withNotification: Bool) {
        let messagePrefix = isEditing ? "" : "새 "
        let category = selectedCategory == .일지 ? "일지" : "일정"
        let action = isEditing ? "수정" : "저장"
        let notificationText = selectedCategory == .일정 && withNotification
            ? " 알림이 설정되었습니다."
            : ""
        
        viewModel.toastMessage = ToastMessage(
            message: "\(messagePrefix)\(category)가 \(action)되었습니다.\(notificationText)",
            type: .success
        )
    }
}

struct RadioButtonRow: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(color)
                            .frame(width: 14, height: 14)
                    }
                }
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
