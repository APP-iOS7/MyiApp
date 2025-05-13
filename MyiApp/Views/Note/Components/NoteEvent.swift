//
//  NoteEvent.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/12/25.
//

import SwiftUI

struct NoteEventList: View {
    var events: [Note]
    var filteredCategory: NoteCategory?
    var onSelectEvent: ((Note) -> Void)
    
    var body: some View {
        let filteredEvents = filteredCategory == nil ? events : events.filter { $0.category == filteredCategory }
        
        if filteredEvents.isEmpty {
            emptyStateView
        } else {
            VStack(spacing: 12) {
                ForEach(filteredEvents) { event in
                    NoteEventRow(event: event) {
                        onSelectEvent(event)
                    }
                }
                .padding(.bottom, 16)
            }
        }
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

struct EmptyStateView: View {
    var title: String
    var subtitle: String
    var imageName: String
    var buttonTitle: String
    var buttonAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("sharkPrimaryLight"))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("sharkPrimaryColor"))
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
            Spacer()
        }
        .frame(height: 300)
    }
}
