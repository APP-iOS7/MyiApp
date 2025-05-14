//
//  NoteEditorView.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/13/25.
//

import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: NoteViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var date: Date
    @State private var selectedCategory: NoteCategory = .일지
    
    let isEditing: Bool
    let noteId: UUID?
    
    init(selectedDate: Date, note: Note? = nil) {
        _date = State(initialValue: selectedDate)
        
        if let note = note {
            _title = State(initialValue: note.title)
            _description = State(initialValue: note.description)
            _date = State(initialValue: note.date)
            _selectedCategory = State(initialValue: note.category)
            self.isEditing = true
            self.noteId = note.id
        } else {
            self.isEditing = false
            self.noteId = nil
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
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                }
                
                if selectedCategory == .일정 {
                    Section(header: Text("알림")) {
                        Toggle("일정 알림", isOn: .constant(false))
                        DatePicker("알림 시간", selection: .constant(date - 3600))
                            .datePickerStyle(.compact)
                            .disabled(true)
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
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "수정" : "저장") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty {
            return
        }
        
        if isEditing, let id = noteId {
            // 수정
            let updatedNote = Note(
                id: id,
                title: title,
                description: description,
                date: date,
                category: selectedCategory
            )
            
            viewModel.updateNote(note: updatedNote)
            viewModel.toastMessage = ToastMessage(message: "\(selectedCategory.rawValue)가 수정되었습니다.", type: .success)
        } else {
            // 새 노트
            viewModel.addNote(
                title: title,
                description: description,
                date: date,
                category: selectedCategory
            )
            viewModel.toastMessage = ToastMessage(message: "새 \(selectedCategory.rawValue)가 저장되었습니다.", type: .success)
        }
        
        dismiss()
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
