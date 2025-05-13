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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 헤더 섹션
                headerSection
                
                // 내용 섹션
                contentSection
                
                // 카테고리별 추가 정보
                if event.category == .건강 || event.category == .발달 {
                    growthChartSection
                }
                
                // 관련 기록 섹션
                relatedEventsSection
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("일지 상세")
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
        .sheet(isPresented: $showingEditSheet) {
            NoteEditorView(selectedDate: event.date, note: event)
                .environmentObject(viewModel)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("일지 삭제"),
                message: Text("이 일지를 삭제하시겠습니까? 삭제한 일지는 복구할 수 없습니다."),
                primaryButton: .destructive(Text("삭제")) {
                    deleteNote()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(event.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("sharkPrimaryDark"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color("sharkPrimaryLight").opacity(0.3))
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private var growthChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("성장 차트")
                .font(.headline)
            
            HStack {
                Rectangle()
                    .fill(Color("sharkPrimaryLight").opacity(0.5))
                    .frame(height: 150)
                    .overlay(
                        Text("성장 차트 영역")
                            .foregroundColor(.gray)
                    )
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
    
    private var relatedEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("관련 기록")
                .font(.headline)
            
            // 여기서는 같은 카테고리의 다른 기록 몇 개만 표시
            ForEach(getRelatedEvents(), id: \.id) { relatedEvent in
                HStack {
                    Circle()
                        .fill(Color("sharkPrimaryLight"))
                        .frame(width: 8, height: 8)
                    
                    Text(relatedEvent.title)
                        .font(.subheadline)
                    
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
            
            if getRelatedEvents().isEmpty {
                Text("관련 기록이 없습니다.")
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
    
    // 관련 이벤트 가져오기 (같은 카테고리의 최근 이벤트 최대 3개)
    private func getRelatedEvents() -> [Note] {
        // 모든 이벤트를 배열로 변환
        let allEvents = viewModel.events.values.flatMap { $0 }
        
        // 같은 카테고리의 다른 이벤트 필터링 (현재 이벤트 제외)
        let sameCategory = allEvents.filter { $0.category == event.category && $0.id != event.id }
        
        // 날짜 기준 최신순 정렬
        let sorted = sameCategory.sorted { $0.date > $1.date }
        
        // 최대 3개까지만 반환
        return Array(sorted.prefix(3))
    }
    
    private func deleteNote() {
        viewModel.deleteNote(note: event)
        presentationMode.wrappedValue.dismiss()
    }
}
