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
    @State private var alertMessage = ""
    @ObservedObject var notificationService = NotificationService.shared
    
    var eventDate: Date
    
    private let reminderOptions = [0, 10, 15, 30, 60, 120, 1440]
    
    var body: some View {
        VStack(spacing: 16) {
            if notificationService.authorizationStatus == .authorized {
                authorizedView
            } else {
                NotificationPermissionView {
                    notificationService.requestAuthorization { granted in
                        if granted {
                            print("알림 권한 획득 성공!")
                            isEnabled = true
                            reminderMinutesBefore = 0
                            reminderTime = eventDate
                        } else {
                            print("알림 권한 획득 실패!")
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: notificationService.authorizationStatus)
        .onAppear {
            notificationService.checkAuthorizationStatus()
            print("NoteReminderView appeared: isEnabled=\(isEnabled), minutesBefore=\(reminderMinutesBefore)")
            print("알림 권한 상태: \(notificationService.authorizationStatus.rawValue)")
            
            if eventDate <= Date() {
                isEnabled = false
            }
        }
        .alert(alertMessage, isPresented: $showInvalidTimeAlert) {
            Button("확인", role: .cancel) { }
        }
    }
    
    private var authorizedView: some View {
        VStack(spacing: 16) {
            Toggle("일정 알림", isOn: $isEnabled)
                .tint(Color("sharkPrimaryColor"))
                .onChange(of: isEnabled) { _, enabled in
                    print("알림 토글 변경: \(enabled)")
                    
                    if enabled {
                        if reminderTime <= Date() || reminderMinutesBefore < 0 {
                            reminderMinutesBefore = 0
                            reminderTime = eventDate
                        }
                    }
                }
            
            if isEnabled {
                VStack(spacing: 16) {
                    HStack {
                        Text("알림 시간")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(reminderOptions, id: \.self) { minutes in
                                Button(action: {
                                    if minutes == 0 {
                                        reminderMinutesBefore = 0
                                        reminderTime = eventDate
                                    } else {
                                        let newReminderTime = eventDate.addingTimeInterval(TimeInterval(-minutes * 60))
                                        if newReminderTime > Date() {
                                            reminderMinutesBefore = minutes
                                            reminderTime = newReminderTime
                                            print("알림 옵션 선택: \(minutes)분 전, 시간: \(reminderTime)")
                                        } else {
                                            showInvalidTimeAlert = true
                                            alertMessage = "선택한 시간이 현재보다 이전입니다. 다른 옵션을 선택해주세요."
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(minutesToString(minutes))
                                        if reminderMinutesBefore == minutes {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                            
                            Button(action: {
                                tempReminderTime = reminderTime
                                showTimePicker = true
                                print("직접 설정 시작")
                            }) {
                                HStack {
                                    Text("직접 설정")
                                    if reminderMinutesBefore == -1 {
                                        Image(systemName: "checkmark")
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
                                    if tempReminderTime >= eventDate {
                                        showInvalidTimeAlert = true
                                        alertMessage = "알림 시간은 일정 시작 시간보다 이전이어야 합니다."
                                        print("선택한 알림 시간이 일정보다 이후임: \(tempReminderTime) >= \(eventDate)")
                                    } else if tempReminderTime <= Date() {
                                        showInvalidTimeAlert = true
                                        alertMessage = "알림 시간은 현재 시간보다 이후여야 합니다."
                                        print("선택한 알림 시간이 현재보다 이전임: \(tempReminderTime) <= \(Date())")
                                    } else {
                                        reminderTime = tempReminderTime
                                        
                                        let diffSeconds = eventDate.timeIntervalSince(tempReminderTime)
                                        let diffMinutes = Int(diffSeconds / 60)
                                        print("알림 시간 차이: \(diffMinutes)분")
                                        
                                        if reminderOptions.contains(diffMinutes) {
                                            reminderMinutesBefore = diffMinutes
                                        } else {
                                            reminderMinutesBefore = -1
                                        }
                                        
                                        print("알림 시간 설정 완료: \(reminderTime), \(reminderMinutesBefore)분 전")
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
                    
                    if reminderMinutesBefore == 0 {
                        Text("일정 시작 시간에 알림을 받습니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if reminderMinutesBefore > 0 {
                        Text("일정이 시작되기 \(minutesToString(reminderMinutesBefore)) 알림을 받습니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("설정한 시간에 알림을 받습니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
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
        return formatter.string(from: reminderTime)
    }
    
    private func minutesToString(_ minutes: Int) -> String {
        switch minutes {
        case 0:
            return "일정 시간"
        case -1:
            return "사용자 지정"
        case 1440:
            return "1일 전"
        case let m where m >= 60:
            return "\(m / 60)시간 전"
        default:
            return "\(minutes)분 전"
        }
    }
}
