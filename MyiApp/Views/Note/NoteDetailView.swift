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
    @State private var selectedImageURL: String? = nil
    @State private var showingImageViewer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 헤더
                headerSection
                
                // 내용
                contentSection
                
                // 이미지 섹션
                if event.category == .일지 && !event.imageURLs.isEmpty {
                    imagesSection
                }
                
                if event.category == .일정 {
                    reminderSection
                }
                
                relatedEventsSection
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
            if viewModel.toastMessage != nil {
                presentationMode.wrappedValue.dismiss()
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
        .fullScreenCover(isPresented: $showingImageViewer) {
            if let selectedURL = selectedImageURL {
                ImageViewerView(imageURL: selectedURL, onDismiss: {
                    showingImageViewer = false
                })
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
            Text("상세 내용")
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
    
    // 이미지 갤러리 섹션
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("이미지")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(event.imageURLs, id: \.self) { url in
                    Button(action: {
                        selectedImageURL = url
                        showingImageViewer = true
                    }) {
                        AsyncImageView(url: url)
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    // 일정 알림 섹션
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("알림 정보")
                .font(.headline)
            
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("알림 예정(미구현입니다)")
                        .font(.subheadline)
                    
                    Text("일정 30분 전")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                }) {
                    Text("변경")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color("sharkCardBackground"))
            .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var relatedEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("같은 카테고리의 기록")
                .font(.headline)
            
            ForEach(getRelatedEvents(), id: \.id) { relatedEvent in
                Button {
                } label: {
                    HStack {
                        Circle()
                            .fill(categoryColor(for: relatedEvent.category))
                            .frame(width: 8, height: 8)
                        
                        Text(relatedEvent.title)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(relatedEvent.date.formattedKoreanDateString())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("sharkCardBackground"))
                    )
                }
            }
            
            if getRelatedEvents().isEmpty {
                Text("같은 카테고리의 다른 기록이 없습니다.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private func getRelatedEvents() -> [Note] {
        let allEvents = viewModel.events.values.flatMap { $0 }
        let sameCategory = allEvents.filter { $0.category == event.category && $0.id != event.id }
        let sorted = sameCategory.sorted { $0.date > $1.date }
        return Array(sorted.prefix(3))
    }
    
    private func deleteNote() {
        if event.category == .일지 {
            viewModel.toastMessage = ToastMessage(message: "일지가 삭제되었습니다.", type: .info)
        } else {
            viewModel.toastMessage = ToastMessage(message: "일정이 삭제되었습니다.", type: .info)
        }
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

// 전체 화면 이미지 뷰어
struct ImageViewerView: View {
    let imageURL: String
    var onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                    
                    AsyncImageView(url: imageURL)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1), 5)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation {
                                scale = scale > 1 ? 1 : 2
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                        .onAppear {
                            isLoading = false
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
}
