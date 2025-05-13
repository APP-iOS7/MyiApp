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
    @State private var selectedCategory: NoteCategory = .일상
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let categories: [NoteCategory] = NoteCategory.allCases
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
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
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
            }
            .navigationTitle(isEditing ? "일지 수정" : "일지 작성")
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    private func saveNote() {
        if title.isEmpty {
            alertMessage = "제목을 입력해주세요."
            showAlert = true
            return
        }
        
        if isEditing, let id = noteId {
            // 수정 모드
            let updatedNote = Note(
                id: id,
                title: title,
                description: description,
                date: date,
                category: selectedCategory
            )
            
            viewModel.updateNote(note: updatedNote)
            alertMessage = "일지가 수정되었습니다."
        } else {
            // 새 노트 추가 모드
            viewModel.addNote(
                title: title,
                description: description,
                date: date,
                category: selectedCategory
            )
            alertMessage = "새 일지가 저장되었습니다."
        }
        
        showAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

#Preview {
    NoteEditorView(selectedDate: Date())
        .environmentObject(NoteViewModel())
}
