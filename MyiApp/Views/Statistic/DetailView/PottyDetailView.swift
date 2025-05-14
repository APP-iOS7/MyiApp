//
//  PottyDetailView.swift
//  MyiApp
//
//  Created by 이민서 on 5/13/25.
//

import SwiftUI

struct PottyDetailView: View {
    
    let records = Record.mockTestRecords
    
    @State private var selectedDate = Date()
    @State private var selectedMode = "일"
    @State private var showCalendar = false
    let modes = ["일", "주", "월"]
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if selectedMode == "일" {
            formatter.dateFormat = "MM월 dd일"
            return formatter.string(from: selectedDate)
        } else if selectedMode == "주" {
            let calendar = Calendar(identifier: .gregorian)
            var mondayStartCalendar = calendar
            mondayStartCalendar.firstWeekday = 2
            
            let startOfWeek = mondayStartCalendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            let endOfWeek = mondayStartCalendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM월 dd일"
            formatter.locale = Locale(identifier: "ko_KR")
            
            let startString = formatter.string(from: startOfWeek)
            let endString = formatter.string(from: endOfWeek)
            
            return "\(startString) ~ \(endString)"
            
        } else {
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        ZStack {
            mainScrollView
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    if let currentIndex = modes.firstIndex(of: selectedMode) {
                        if horizontalAmount < -50 {
                            let nextIndex = (currentIndex + 1) % modes.count
                            selectedMode = modes[nextIndex]
                        } else if horizontalAmount > 50 {
                            let prevIndex = (currentIndex - 1 + modes.count) % modes.count
                            selectedMode = modes[prevIndex]
                        }
                    }
                }
        )
        .navigationTitle("배변 통계")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    toggleMode
                    Spacer()
                    dateMove
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .padding()
        }
        
    }
    private var toggleMode: some View {
        HStack(spacing: 4) {
            ForEach(modes, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                }) {
                    Text(mode)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedMode == mode ? Color("sharkPrimaryColor") : Color.gray)
                        .frame(maxWidth: 90, minHeight: 32)
                        .background(
                            ZStack {
                                if selectedMode == mode {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("sharkPrimaryColor"), lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                        )
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(width: 200, height: 50)
    }
    private var dateMove: some View {
        Group {
            HStack {
                Button(action: {
                    let calendar = Calendar.current
                    switch selectedMode {
                    case "일":
                        selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    case "주":
                        selectedDate = calendar.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
                    case "월":
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    default:
                        break
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showCalendar.toggle()
                    }
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                }
                
                Text(formattedDateString)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    let calendar = Calendar.current
                    switch selectedMode {
                    case "일":
                        selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    case "주":
                        selectedDate = calendar.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
                    case "월":
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    default:
                        break
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
            if showCalendar {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .transition(.opacity)
                .tint(Color("sharkPrimaryColor"))
            }
        }
        
    }
}
