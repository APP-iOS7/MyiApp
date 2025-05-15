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
    @State private var notificationTimeString: String?
    
    let isEditing: Bool
    let noteId: UUID?
    
    init(selectedDate: Date, note: Note? = nil) {
        _date = State(initialValue: selectedDate)
        
        // 새로운 일정인 경우 일정 시간을 기본값으로
        if note == nil {
            _reminderTime = State(initialValue: selectedDate) // 일정 시간 자체를 알림 시간으로
            _reminderMinutesBefore = State(initialValue: 0) // 0은 일정 시간과 동일함을 의미
        } else {
            // 기존 일정 수정의 경우 - 임시 초기값 설정 (나중에 업데이트됨)
            _reminderTime = State(initialValue: note!.date)
            _reminderMinutesBefore = State(initialValue: 0) // 일정 시간과 동일
        }
        
        if let note = note {
            _title = State(initialValue: note.title)
            _description = State(initialValue: note.description)
            _date = State(initialValue: note.date)
            _selectedCategory = State(initialValue: note.category)
            _existingImageURLs = State(initialValue: note.imageURLs)
            
            self.isEditing = true
            self.noteId = note.id
        } else {
            self.isEditing = false
            self.noteId = nil
        }
    }
    
    // onAppear에서 알림 상태 확인
    private func checkNotificationStatus() {
        if let id = noteId, selectedCategory == .일정 {
            NotificationService.shared.checkNotificationExists(with: id.uuidString) { exists in
                DispatchQueue.main.async {
                    self.isReminderEnabled = exists
                    
                    // 기존 알림이 있다면 예상 시간 가져오기
                    if exists {
                        // 기존 알림 시간 정보 가져오기
                        NotificationService.shared.getNotificationTriggerDate(with: id.uuidString) { triggerDate in
                            DispatchQueue.main.async {
                                if let triggerDate = triggerDate {
                                    self.reminderTime = triggerDate
                                    
                                    // 분 단위 차이 계산
                                    let diffSeconds = self.date.timeIntervalSince(triggerDate)
                                    let diffMinutes = Int(diffSeconds / 60)
                                    
                                    if diffMinutes > 0 {
                                        // 표준 옵션과 일치하는지 확인
                                        if [10, 15, 30, 60, 120, 1440].contains(diffMinutes) {
                                            self.reminderMinutesBefore = diffMinutes
                                        } else {
                                            self.reminderMinutesBefore = -1 // 사용자 지정 값
                                        }
                                    } else {
                                        // 미래 시간이면 일정 시간으로 설정
                                        self.reminderTime = self.date
                                        self.reminderMinutesBefore = -1 // 사용자 지정 값
                                    }
                                } else {
                                    // 알림 시간 정보가 없으면 일정 시간 사용
                                    self.reminderTime = self.date
                                    self.reminderMinutesBefore = -1 // 사용자 지정 값
                                }
                            }
                        }
                    } else {
                        // 알림이 없는 경우 일정 시간으로 초기화
                        self.reminderTime = self.date
                        self.reminderMinutesBefore = -1 // 사용자 지정 값
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
                        
                        // 일정 카테고리 옵션
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
                            // 날짜가 변경되면 자동으로 알림 시간도 업데이트
                            reminderTime = newValue.addingTimeInterval(TimeInterval(-reminderMinutesBefore * 60))
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
            .onChange(of: viewModel.isLoading) { _, newValue in
                if isSaving && !newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSaving = false
                        dismiss()
                    }
                }
            }
            .onAppear {
                // 뷰가 나타날 때 알림 상태 확인
                checkNotificationStatus()
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty {
            return
        }
        
        isSaving = true
        
        // 알림 처리
        if selectedCategory == .일정 {
            if isReminderEnabled {
                // 알림 시간 계산 (일정에서 minutesBefore 만큼 이전)
                let timeDiff = Int(date.timeIntervalSince(reminderTime) / 60)
                reminderMinutesBefore = timeDiff > 0 ? timeDiff : 30
                
                notificationTimeString = NotificationService.shared.getNotificationTimeText(for: date, minutesBefore: reminderMinutesBefore)
            } else if let id = noteId {
                // 알림이 비활성화되었다면 기존 알림 취소
                NotificationService.shared.cancelNotification(with: id.uuidString)
            }
        }
        
        if isEditing, let id = noteId {
            if !selectedImages.isEmpty && selectedCategory == .일지 {
                let updatedNote = Note(
                    id: id,
                    title: title,
                    description: description,
                    date: date,
                    category: selectedCategory,
                    imageURLs: existingImageURLs
                )
                
                viewModel.updateNoteWithImages(note: updatedNote, newImages: selectedImages)
            } else {
                let updatedNote = Note(
                    id: id,
                    title: title,
                    description: description,
                    date: date,
                    category: selectedCategory,
                    imageURLs: existingImageURLs
                )
                
                viewModel.updateNote(note: updatedNote)
                
    // 알림 설정
    if selectedCategory == .일정 && isReminderEnabled {
        if NotificationService.shared.authorizationStatus == .authorized {
            let notificationResult = NotificationService.shared.scheduleNotification(for: updatedNote, minutesBefore: reminderMinutesBefore)
            if notificationResult == nil {
                viewModel.toastMessage = ToastMessage(message: "알림 권한이 없어 알림이 설정되지 않았습니다.", type: .error)
            }
        } else {
            NotificationService.shared.requestAuthorization { granted in
                if granted {
                    DispatchQueue.main.async {
                        _ = NotificationService.shared.scheduleNotification(for: updatedNote, minutesBefore: reminderMinutesBefore)
                    }
                } else {
                    viewModel.toastMessage = ToastMessage(message: "알림 권한이 없어 알림이 설정되지 않았습니다.", type: .error)
                }
            }
        }
    }
                
                if selectedCategory == .일지 {
                    viewModel.toastMessage = ToastMessage(message: "일지가 수정되었습니다.", type: .success)
                } else {
                    viewModel.toastMessage = ToastMessage(message: "일정이 수정되었습니다.", type: .success)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSaving = false
                    dismiss()
                }
            }
        } else {
            // 새로운 노트 생성
            let newNoteId = UUID()
            
            if !selectedImages.isEmpty && selectedCategory == .일지 {
                let newNote = Note(
                    id: newNoteId,
                    title: title,
                    description: description,
                    date: date,
                    category: selectedCategory
                )
                
                viewModel.addNoteWithImages(
                    title: title,
                    description: description,
                    date: date,
                    category: selectedCategory,
                    images: selectedImages
                )
                
                // 이미지 업로드 후 저장이 완료되면 알림 처리
                if selectedCategory == .일정 && isReminderEnabled {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NotificationService.shared.scheduleNotification(for: newNote, minutesBefore: reminderMinutesBefore)
                    }
                }
            } else {
                let newNote = Note(
                    id: newNoteId,
                    title: title,
                    description: description,
                    date: date,
                    category: selectedCategory
                )
                
                viewModel.addNote(
                    title: title,
                    description: description,
                    date: date,
                    category: selectedCategory
                )
                
                // 알림 설정
                if selectedCategory == .일정 && isReminderEnabled {
                    if NotificationService.shared.authorizationStatus == .authorized {
                        let notificationResult = NotificationService.shared.scheduleNotification(for: newNote, minutesBefore: reminderMinutesBefore)
                        if notificationResult == nil {
                            viewModel.toastMessage = ToastMessage(message: "알림 권한이 없어 알림이 설정되지 않았습니다.", type: .error)
                        } else {
                            let message = "새 일정이 저장되었습니다. 알림이 설정되었습니다."
                            viewModel.toastMessage = ToastMessage(message: message, type: .success)
                        }
                    } else {
                        NotificationService.shared.requestAuthorization { granted in
                            if granted {
                                DispatchQueue.main.async {
                                    _ = NotificationService.shared.scheduleNotification(for: newNote, minutesBefore: reminderMinutesBefore)
                                    let message = "새 일정이 저장되었습니다. 알림이 설정되었습니다."
                                    viewModel.toastMessage = ToastMessage(message: message, type: .success)
                                }
                            } else {
                                viewModel.toastMessage = ToastMessage(message: "알림 권한이 없어 알림이 설정되지 않았습니다.", type: .error)
                            }
                        }
                    }
                } else {
                    if selectedCategory == .일지 {
                        viewModel.toastMessage = ToastMessage(message: "새 일지가 저장되었습니다.", type: .success)
                    } else {
                        viewModel.toastMessage = ToastMessage(message: "새 일정이 저장되었습니다.", type: .success)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSaving = false
                    dismiss()
                }
            }
        }
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
