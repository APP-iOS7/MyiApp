//
//  NoteReminderView.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/15/25.
//

import SwiftUI

struct NoteReminderView: View {
    @Binding var isEnabled: Bool
    @Binding var reminderTime: Date
    @Binding var reminderMinutesBefore: Int
    @State private var showTimePicker = false
    @State private var tempReminderTime: Date = Date()
    @State private var showInvalidTimeAlert = false
    @ObservedObject var notificationService = NotificationService.shared
    
    var eventDate: Date
    
    private let reminderOptions = [10, 15, 30, 60, 120, 1440]
    
    var body: some View {
        VStack(spacing: 16) {
            if notificationService.authorizationStatus == .authorized {
                authorizedView
            } else {
                NotificationPermissionView {
                    isEnabled = true
                }
            }
        }
        .animation(.easeInOut, value: notificationService.authorizationStatus)
        .onAppear {
            notificationService.checkAuthorizationStatus()
        }
        .alert("알림 시간 오류", isPresented: $showInvalidTimeAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("알림 시간은 일정 시작 시간보다 이전이어야 합니다.\n다시 설정해주세요.")
        }
    }
    
    private var authorizedView: some View {
        VStack(spacing: 16) {
            Toggle("일정 알림", isOn: $isEnabled)
                .tint(Color("sharkPrimaryColor"))
            
            if isEnabled {
                VStack(spacing: 16) {
                    HStack {
                        Text("알림 시간")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(reminderOptions, id: \.self) { minutes in
                                Button(action: {
                                    reminderMinutesBefore = minutes
                                    // 알림 시간 업데이트
                                    reminderTime = eventDate.addingTimeInterval(TimeInterval(-minutes * 60))
                                }) {
                                    HStack {
                                        Text(minutesToString(minutes))
                                        if reminderMinutesBefore == minutes {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(minutesToString(reminderMinutesBefore))
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Button(action: {
                        tempReminderTime = reminderTime
                        showTimePicker = true
                    }) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color("sharkPrimaryColor"))
                            
                            Text(formattedReminderTime)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color("sharkCardBackground"))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showTimePicker) {
                        VStack(spacing: 20) {
                            Text("알림 시간 설정")
                                .font(.headline)
                                .padding(.top)
                            
                            DatePicker("알림 시간", selection: $tempReminderTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .onChange(of: tempReminderTime) { _, _ in
                                }
                            
                            HStack {
                                Button("취소") {
                                    showTimePicker = false
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                                
                                Button("확인") {
                                    // 시간이 유효한지 확인
                                    let diffSeconds = eventDate.timeIntervalSince(tempReminderTime)
                                    let diffMinutes = Int(diffSeconds / 60)
                                    
                                    if diffMinutes <= 0 {
                                        showInvalidTimeAlert = true
                                    } else {
                                        reminderTime = tempReminderTime
                                        
                                        if tempReminderTime == eventDate {
                                            reminderMinutesBefore = 0
                                        }
                                        else if reminderOptions.contains(diffMinutes) {
                                            reminderMinutesBefore = diffMinutes
                                        } else {
                                            reminderMinutesBefore = -1
                                        }
                                        
                                        showTimePicker = false
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("sharkPrimaryColor"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .presentationDetents([.height(350)])
                    }
                    
                    Text("일정이 시작되기 전 알림을 받습니다")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        
        if reminderMinutesBefore == -1 {
            return formatter.string(from: reminderTime)
        }
        
        return formatter.string(from: reminderTime)
    }
    
    private func minutesToString(_ minutes: Int) -> String {
        if minutes == 0 {
            return "일정 시간"
        } else if minutes == -1 {
            return "사용자 지정"
        } else if minutes == 1440 {
            return "1일 전"
        } else if minutes >= 60 {
            return "\(minutes / 60)시간 전"
        } else {
            return "\(minutes)분 전"
        }
    }
}
