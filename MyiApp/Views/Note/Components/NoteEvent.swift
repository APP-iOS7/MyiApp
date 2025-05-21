//
//  NoteEvent.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/12/25.
//

import SwiftUI

struct NoteEventList: View {
    @EnvironmentObject private var viewModel: NoteViewModel
    var events: [Note]
    var filteredCategory: NoteCategory?
    var onSelectEvent: ((Note) -> Void)
    @State private var showingDeleteAlert = false
    @State private var noteToDelete: Note?
    
    var body: some View {
        let filteredEvents = filteredCategory == nil ? events : events.filter { $0.category == filteredCategory }
        
        if filteredEvents.isEmpty {
            emptyStateView
        } else {
            LazyVStack(spacing: 8) {
                ForEach(filteredEvents) { event in
                    NoteEventRow(event: event)
                        .onTapGesture {
                            onSelectEvent(event)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                noteToDelete = event
                                showingDeleteAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
                .padding(.bottom, 16)
            }
            .alert("삭제 확인", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) {
                    noteToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let note = noteToDelete {
                        deleteNote(note)
                    }
                    noteToDelete = nil
                }
            } message: {
                if let note = noteToDelete {
                    Text("\(note.title)을(를) 삭제하시겠습니까?")
                } else {
                    Text("이 항목을 삭제하시겠습니까?")
                }
            }
        }
    }
    
    private func deleteNote(_ note: Note) {
        // 일정인 경우 알림 취소
        if note.category == .일정 {
            NotificationService.shared.cancelNotification(with: note.id.uuidString)
        }
        
        // 삭제 토스트 메시지 설정
        let category = note.category == .일지 ? "일지" : "일정"
        viewModel.toastMessage = ToastMessage(message: "\(category)가 삭제되었습니다.", type: .info)
        
        // 노트 삭제
        viewModel.deleteNote(note: note)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "doc.text.magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("sharkPrimaryLight"))
                
                Text(filteredCategory == nil ?
                     "이 날의 기록이 없습니다." :
                     "해당 카테고리의 기록이 없습니다.")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("새로운 일지를 작성해보세요.")
                    .font(.subheadline)
                    .foregroundColor(.gray.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
            Spacer()
        }
        .frame(height: 250)
    }
}

struct NoteEventRow: View {
    var event: Note
    var onTap: (() -> Void)? = nil
    @EnvironmentObject private var viewModel: NoteViewModel
    @State private var showingDeleteAlert = false
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @GestureState private var isDragging = false
    
    private let deleteWidth: CGFloat = -70
    
    var body: some View {
        ZStack {
            // 삭제 버튼 배경
            HStack(spacing: 0) {
                Spacer()
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    VStack {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 70)
                    .background(Color.red.opacity(0.7))
                }
                .cornerRadius(20)
            }
            .opacity(offset < -10 ? 1 : 0)
            
            // 메인 콘텐츠
            HStack(spacing: 12) {
                if event.category == .일지 && !event.imageURLs.isEmpty {
                    CustomAsyncImageView(imageUrlString: event.imageURLs[0])
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(categoryColor(for: event.category).opacity(0.3), lineWidth: 2)
                        )
                } else {
                    Image(systemName: categoryIcon(for: event.category))
                        .foregroundColor(categoryColor(for: event.category))
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(categoryColor(for: event.category).opacity(0.2))
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if event.category == .일지 && event.imageURLs.count > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.system(size: 10))
                            Text("\(event.imageURLs.count)")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.systemGray6))
                        )
                    }
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(10)
            .contentShape(Rectangle())
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .local)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, deleteWidth)
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < deleteWidth/2 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = deleteWidth
                                isSwiped = true
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        if isSwiped {
                            withAnimation(.spring()) {
                                offset = 0
                                isSwiped = false
                            }
                        } else {
                            onTap?()
                        }
                    }
            )
        }
        .alert("삭제 확인", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) {
                withAnimation(.spring()) {
                    offset = 0
                    isSwiped = false
                }
            }
            Button("삭제", role: .destructive) {
                deleteNote()
            }
        } message: {
            Text("\(event.title)을(를) 삭제하시겠습니까?")
        }
        .padding(.horizontal)
        .onAppear {
            offset = 0
            isSwiped = false
        }
        .onDisappear {
            offset = 0
            isSwiped = false
        }
    }
    
    private func deleteNote() {
        if event.category == .일정 {
            NotificationService.shared.cancelNotification(with: event.id.uuidString)
        }
        
        let category = event.category == .일지 ? "일지" : "일정"
        viewModel.toastMessage = ToastMessage(message: "\(category)가 삭제되었습니다.", type: .info)
        
        viewModel.deleteNote(note: event)
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
