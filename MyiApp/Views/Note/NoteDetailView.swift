//
//  NoteDetailView.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/13/25.
//

import SwiftUI

struct NoteDetailView: View {
    let event: Note
    @EnvironmentObject private var viewModel: NoteViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var hasNotification = false
    @State private var notificationTime: String?
    @State private var refreshTrigger = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                
                if event.category == .일지 && !event.imageURLs.isEmpty {
                    ImageGallery(imageURLs: event.imageURLs)
                        .padding(.top, 0)
                }
                
                contentSection
                    .padding(.top, 16)
                
                if event.category == .일정 {
                    reminderSection
                        .padding(.top, 16)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(event.category == .일지 ? "일지 상세" : "일정 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("수정", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet, onDismiss: {
            if event.category == .일정 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    refreshTrigger.toggle()
                    checkNotificationStatus()
                }
            }
            
            if viewModel.toastMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }) {
            NoteEditorView(selectedDate: event.date, note: event)
                .environmentObject(viewModel)
        }
        .alert("삭제 시 되돌릴 수 없습니다", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                deleteNote()
            }
        } message: {
            Text(event.category == .일지 ?
                "이 일지는 영구적으로 삭제되며,\n복구할 수 없습니다." :
                "이 일정은 영구적으로 삭제되며,\n복구할 수 없습니다.")
        }
        .onAppear {
            print("NoteDetailView appeared for: \(event.id), category: \(event.category.rawValue)")
            if event.category == .일정 {
                checkNotificationStatus()
            }
        }
        .onChange(of: refreshTrigger) { _, _ in
            if event.category == .일정 {
                checkNotificationStatus()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: categoryIcon(for: event.category))
                        .foregroundColor(categoryColor(for: event.category))
                    
                    Text(event.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(categoryColor(for: event.category))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(categoryColor(for: event.category).opacity(0.2))
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
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("내용")
                .font(.headline)
            
            Text(event.description)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    // 일정 알림 섹션 - 완전히 개선됨
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("알림 정보")
                .font(.headline)
            
            if hasNotification, let notificationTime = notificationTime {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("알림 예정")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(notificationTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Text("변경")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color("sharkCardBackground"))
                .cornerRadius(8)
            } else {
                HStack {
                    Image(systemName: "bell.slash")
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("알림 없음")
                            .font(.subheadline)
                        
                        Text("이 일정에는 알림이 설정되어 있지 않습니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Text("설정")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color("sharkCardBackground"))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
        .id("\(hasNotification)-\(notificationTime ?? "none")-\(refreshTrigger)") // 강제 새로고침 처리
    }
    
    private func checkNotificationStatus() {
        print("알림 상태 확인 시작: \(event.id.uuidString)")
        
        if let enabled = event.notificationEnabled,
           enabled,
           let time = event.notificationTime {
            
            hasNotification = true
            setNotificationTimeText(triggerDate: time)
            print("Note 객체에서 알림 정보 발견: \(time)")
            return
        }
        
        NotificationService.shared.findNotificationForNote(noteId: event.id.uuidString) { exists, triggerDate, title in
            print("알림 상태 결과: 존재=\(exists), 시간=\(String(describing: triggerDate)), 제목=\(String(describing: title))")
            
            DispatchQueue.main.async {
                self.hasNotification = exists
                
                if exists, let triggerDate = triggerDate {
                    self.setNotificationTimeText(triggerDate: triggerDate)
                    
                    self.viewModel.updateNoteNotification(
                        noteId: self.event.id,
                        enabled: true,
                        time: triggerDate
                    )
                } else {
                    self.notificationTime = nil
                    
                    self.viewModel.updateNoteNotification(
                        noteId: self.event.id,
                        enabled: false,
                        time: nil
                    )
                }
            }
        }
    }
    
    private func setNotificationTimeText(triggerDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        
        self.notificationTime = formatter.string(from: triggerDate)
        
        let diffSeconds = self.event.date.timeIntervalSince(triggerDate)
        let diffMinutes = Int(diffSeconds / 60)
        
        if diffMinutes >= 60 {
            if diffMinutes % 60 == 0 {
                let hours = diffMinutes / 60
                self.notificationTime! += " (\(hours)시간 전)"
            } else {
                let hours = diffMinutes / 60
                let mins = diffMinutes % 60
                self.notificationTime! += " (\(hours)시간 \(mins)분 전)"
            }
        } else {
            self.notificationTime! += " (\(diffMinutes)분 전)"
        }
    }
    
    private func deleteNote() {
        if event.category == .일정 {
            print("노트 삭제 시 알림 취소: \(event.id.uuidString)")
            NotificationService.shared.cancelNotification(with: event.id.uuidString)
        }
        
        let category = event.category == .일지 ? "일지" : "일정"
        viewModel.toastMessage = ToastMessage(message: "\(category)가 삭제되었습니다.", type: .info)
        
        viewModel.deleteNote(note: event)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func categoryColor(for category: NoteCategory) -> Color {
        switch category {
        case .일지:
            return Color("sharkPrimaryColor")
        case .일정:
            return Color.orange
        }
    }
    
    private func categoryIcon(for category: NoteCategory) -> String {
        switch category {
        case .일지:
            return "note.text"
        case .일정:
            return "calendar"
        }
    }
}
