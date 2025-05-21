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
    
    @State private var isReminderEnabled: Bool = false
    @State private var reminderTime: Date
    @State private var reminderMinutesBefore: Int = 0
    @State private var showAlertMessage = false
    @State private var alertMessage = ""
    
    let isEditing: Bool
    let noteId: UUID?
    
    init(selectedDate: Date, note: Note? = nil) {
        let now = Date()
        if let note = note {
            _date = State(initialValue: note.date)
            _reminderTime = State(initialValue: note.date)
        } else {
            let calendar = Calendar.current
            
            let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let currentTimeComponents = calendar.dateComponents([.hour, .minute], from: now)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = selectedDateComponents.year
            combinedComponents.month = selectedDateComponents.month
            combinedComponents.day = selectedDateComponents.day
            combinedComponents.hour = currentTimeComponents.hour
            combinedComponents.minute = currentTimeComponents.minute
            
            let combinedDate = calendar.date(from: combinedComponents) ?? now
            _date = State(initialValue: combinedDate)
            _reminderTime = State(initialValue: combinedDate)
        }
        
        if let note = note {
            _title = State(initialValue: note.title)
            _description = State(initialValue: note.description)
            _selectedCategory = State(initialValue: note.category)
            _existingImageURLs = State(initialValue: note.imageURLs)
            
            if let notificationEnabled = note.notificationEnabled,
               notificationEnabled {
                _isReminderEnabled = State(initialValue: true)
                
                if let notificationTime = note.notificationTime {
                    _reminderTime = State(initialValue: notificationTime)
                    
                    let diffMinutes = Int(note.date.timeIntervalSince(notificationTime) / 60)
                    if diffMinutes > 0 {
                        _reminderMinutesBefore = State(initialValue: diffMinutes)
                    } else {
                        _reminderMinutesBefore = State(initialValue: 0)
                    }
                }
            } else {
                _isReminderEnabled = State(initialValue: note.category == .일정)
            }
            
            self.isEditing = true
            self.noteId = note.id
        } else {
            _isReminderEnabled = State(initialValue: false)
            
            self.isEditing = false
            self.noteId = nil
        }
    }
    
    private func checkNotificationStatus() {
        guard let id = noteId, selectedCategory == .일정 else { return }
        
        // 모든 알림 출력 (디버깅)
        NotificationService.shared.printAllScheduledNotifications()
        
        if let note = viewModel.getNoteById(id),
           let enabled = note.notificationEnabled,
           enabled,
           let notificationTime = note.notificationTime {
            
            isReminderEnabled = true
            reminderTime = notificationTime
            
            let diffSeconds = note.date.timeIntervalSince(notificationTime)
            let diffMinutes = Int(diffSeconds / 60)
            
            if diffMinutes > 0 {
                reminderMinutesBefore = diffMinutes
            } else {
                reminderMinutesBefore = 0
            }
            
            return
        }
        
        // 실제 알림 시스템에서 확인
        NotificationService.shared.findNotificationForNote(noteId: id.uuidString) { exists, triggerDate, _ in
            
            DispatchQueue.main.async {
                self.isReminderEnabled = exists
                
                if exists, let triggerDate = triggerDate {
                    self.reminderTime = triggerDate
                    
                    let diffMinutes = Int(self.date.timeIntervalSince(triggerDate) / 60)
                    
                    if diffMinutes > 0 {
                        if [0, 10, 15, 30, 60, 120, 1440].contains(diffMinutes) {
                            self.reminderMinutesBefore = diffMinutes
                        } else {
                            self.reminderMinutesBefore = diffMinutes
                        }
                    } else {
                        self.reminderMinutesBefore = 0
                    }
                    
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
                            isReminderEnabled = false
                        }
                        
                        RadioButtonRow(
                            title: "일정",
                            icon: "calendar",
                            color: Color.orange,
                            isSelected: selectedCategory == .일정
                        ) {
                            selectedCategory = .일정
                            isReminderEnabled = true
                            reminderTime = date
                            reminderMinutesBefore = 0
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
                                if reminderMinutesBefore == 0 {
                                    reminderTime = newValue
                                } else {
                                    reminderTime = newValue.addingTimeInterval(TimeInterval(-reminderMinutesBefore * 60))
                                    
                                    if reminderTime < Date() {
                                        let possibleTime = Date().addingTimeInterval(5 * 60)
                                        if possibleTime < newValue {
                                            reminderTime = possibleTime
                                            let diffMinutes = Int(newValue.timeIntervalSince(possibleTime) / 60)
                                            reminderMinutesBefore = diffMinutes
                                        }
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
                checkNotificationStatus()
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty { return }
        
        // 일정인 경우 알림 설정 유효성 검사
        if selectedCategory == .일정 && isReminderEnabled {
            // 알림 시간 유효성 검사
            if reminderTime < Date() {
                alertMessage = "알림 시간은 현재 시간보다 이후여야 합니다."
                showAlertMessage = true
                return // 저장 프로세스 중단
            }
            
            if reminderTime >= date {
                alertMessage = "알림 시간은 일정 시작 시간보다 이전이어야 합니다."
                showAlertMessage = true
                return // 저장 프로세스 중단
            }
        }
        
        isSaving = true
        
        let noteId = self.noteId ?? UUID()
        
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
                        isSaving = false
                        return
                    }
                }
            } else {
                notificationEnabled = false
                if isEditing {
                    NotificationService.shared.cancelNotification(with: noteId.uuidString)
                }
            }
        }
        
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
        
        if !selectedImages.isEmpty && selectedCategory == .일지 {
            if isEditing {
                viewModel.updateNoteWithImages(note: note, newImages: selectedImages)
            } else {
                viewModel.addNoteWithImages(note: note, images: selectedImages)
            }
            
            setSuccessToastMessage(withNotification: notificationEnabled == true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isSaving = false
                dismiss()
            }
            
        } else {
            if isEditing {
                viewModel.updateNote(note: note)
            } else {
                viewModel.addNote(note: note)
            }
            
            setSuccessToastMessage(withNotification: notificationEnabled == true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSaving = false
                dismiss()
            }
        }
    }
    
    private func handleNotificationForEvent(noteId: UUID) -> (success: Bool, time: Date?, message: String?) {
        print("알림 처리: isEnabled=\(isReminderEnabled), noteId=\(noteId)")

        if reminderTime < Date() {
            return (false, nil, "알림 시간은 현재 시간 이후여야 합니다.")
        }
        
        if reminderTime >= date {
            return (false, nil, "알림 시간은 일정 시작 시간보다 이전이어야 합니다.")
        }
        
        let timeDiff = reminderMinutesBefore == 0 ? 0 : max(1, Int(date.timeIntervalSince(reminderTime) / 60))
        
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
