//
//  NotificationService.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/15/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // 알림 권한 상태 확인
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // 알림 권한 요청
    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
                if let error = error {
                    print("알림 권한 요청 에러: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    // 알림 예약
    func scheduleNotification(for note: Note, minutesBefore: Int = 30) -> String? {
        print("알림 예약 시도: 노트 ID \(note.id.uuidString), \(minutesBefore)분 전")
        
        // 알림 권한이 없으면 알림을 예약하지 않음
        if authorizationStatus != .authorized {
            print("알림 권한 없음: \(authorizationStatus)")
            return nil
        }
        
        // 이미 존재하는 알림 삭제 (수정 시)
        cancelNotification(with: note.id.uuidString)
        
        let content = UNMutableNotificationContent()
        content.title = "일정 알림"
        content.body = note.title
        content.sound = .default
        
        // 분 단위 값이 올바른지 확인
        var minutes = minutesBefore
        if minutes <= 0 { // 0 또는 음수인 경우 1분으로 설정
            minutes = 1
            print("알림 시간이 0 또는 음수입니다. 1분 전으로 설정합니다.")
        }
        print("설정할 알림 시간: \(minutes)분 전")
        
        // 알림 시간 계산 (일정 시간 - minutes분)
        let triggerDate = note.date.addingTimeInterval(TimeInterval(-minutes * 60))
        
        // 현재 시간보다 이전이면 알림 예약하지 않음
        if triggerDate <= Date() {
            print("알림 시간이 현재보다 이전: \(triggerDate)")
            return "이미 지난 시간으로 알림을 설정할 수 없습니다."
        }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("알림 예약 성공: \(minutes)분 전 (\(triggerDate))")
            }
        }
        
        // 확인을 위해 모든 예약된 알림 출력
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("현재 예약된 알림 개수: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    print("- 알림 ID: \(request.identifier), 시간: \(date)")
                }
            }
        }
        
        // 포맷된 알림 시간 반환
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: triggerDate)
    }
    
    // 알림 취소
    func cancelNotification(with identifier: String) {
        print("알림 취소: ID \(identifier)")
        
        // 취소 전에 현재 예약된 알림이 있는지 확인
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == identifier }
            print("취소 대상 알림 존재 여부: \(exists)")
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 취소 후 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let stillExists = requests.contains { $0.identifier == identifier }
                print("취소 후 알림 존재 여부: \(stillExists)")
            }
        }
    }
    
    // 알림 시간 텍스트 생성
    func getNotificationTimeText(for date: Date, minutesBefore: Int = 30) -> String {
        // 일정 시간과 동일한 경우
        if minutesBefore == 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM월 dd일 a h:mm"
            formatter.amSymbol = "오전"
            formatter.pmSymbol = "오후"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        }
        
        // 사용자 정의 값인 경우
        if minutesBefore < 0 {
            // 일정 시간과 동일하게 표시
            let formatter = DateFormatter()
            formatter.dateFormat = "MM월 dd일 a h:mm"
            formatter.amSymbol = "오전"
            formatter.pmSymbol = "오후"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        }
        
        let notificationDate = date.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: notificationDate)
    }
    
    // 예약된 알림 확인
    func checkNotificationExists(with identifier: String, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == identifier }
            DispatchQueue.main.async {
                completion(exists)
            }
        }
    }
    
    // 예약된 알림의 트리거 시간 가져오기
    func getNotificationTriggerDate(with identifier: String, completion: @escaping (Date?) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let matchingRequest = requests.first { $0.identifier == identifier }
            
            if let request = matchingRequest,
               let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let triggerDate = trigger.nextTriggerDate() {
                DispatchQueue.main.async {
                    completion(triggerDate)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // 설정 앱의 알림 설정 화면 열기
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
