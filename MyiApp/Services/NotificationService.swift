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
    
    // 알림 예약 - 완전히 수정됨: 예약 결과로 알림 시간 반환
    @discardableResult
    func scheduleNotification(for note: Note, minutesBefore: Int = 30) -> (success: Bool, time: Date?, message: String?) {
        print("📅 알림 예약 시도: 노트 ID \(note.id.uuidString), \(minutesBefore)분 전")
        
        // 1. 알림 권한 확인
        if authorizationStatus != .authorized {
            print("📅 알림 권한 없음: \(authorizationStatus)")
            return (false, nil, "알림 권한이 필요합니다")
        }
        
        // 2. 기존 알림 취소 (같은 ID에 대한 중복 방지)
        cancelNotification(with: note.id.uuidString)
        
        // 3. 분 단위 값이 올바른지 확인
        var minutes = minutesBefore
        if minutes <= 0 { // 0 또는 음수인 경우 30분으로 설정
            minutes = 30
            print("📅 알림 시간 조정: \(minutes)분 전으로 설정")
        }
        
        // 4. 알림 시간 계산 (일정 시간 - minutes분)
        let triggerDate = note.date.addingTimeInterval(TimeInterval(-minutes * 60))
        
        // 5. 현재 시간보다 이전이면 알림 예약하지 않음
        if triggerDate <= Date() {
            print("📅 알림 시간이 현재보다 이전: \(triggerDate)")
            return (false, nil, "이미 지난 시간으로 알림을 설정할 수 없습니다.")
        }
        
        // 6. 알림 콘텐츠 생성
        let content = UNMutableNotificationContent()
        content.title = "일정 알림"
        content.body = note.title
        content.sound = .default
        
        // 중요: 알림 ID와 노트 ID 연결을 위한 userInfo 저장
        content.userInfo = [
            "noteId": note.id.uuidString,
            "title": note.title,
            "date": note.date.timeIntervalSince1970
        ]
        
        // 7. 알림 트리거 생성
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 8. 알림 요청 생성 및 등록
        // 중요: 알림 식별자로 노트 ID를 사용
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        
        var isSuccessful = true
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().add(request) { error in
            defer { semaphore.signal() }
            
            if let error = error {
                print("📅 알림 예약 실패: \(error.localizedDescription)")
                isSuccessful = false
            } else {
                print("📅 알림 예약 성공: \(minutes)분 전 (\(triggerDate)), ID: \(note.id.uuidString)")
            }
        }
        
        // 최대 1초간 결과 대기
        _ = semaphore.wait(timeout: .now() + 1.0)
        
        // 디버깅: 모든 예약된 알림 출력
        printAllScheduledNotifications()
        
        if isSuccessful {
            return (true, triggerDate, nil)
        } else {
            return (false, nil, "알림 설정에 실패했습니다")
        }
    }
    
    // 알림 취소
    func cancelNotification(with identifier: String) {
        print("📅 알림 취소: ID \(identifier)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 취소 후 로그 출력
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.printAllScheduledNotifications()
        }
    }
    
    // 알림 시간 텍스트 생성
    func getNotificationTimeText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: date)
    }
    
    // 전체 알림 목록에서 특정 노트 ID에 대한 알림 찾기
    func findNotificationForNote(noteId: String, completion: @escaping (Bool, Date?, String?) -> Void) {
        print("📅 노트 ID로 알림 찾기: \(noteId)")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // 1. 직접 ID 매칭
            if let matchingRequest = requests.first(where: { $0.identifier == noteId }),
               let trigger = matchingRequest.trigger as? UNCalendarNotificationTrigger,
               let triggerDate = trigger.nextTriggerDate() {
                
                print("📅 ID로 알림 발견: \(noteId)")
                DispatchQueue.main.async {
                    completion(true, triggerDate, matchingRequest.content.title)
                }
                return
            }
            
            // 2. userInfo에서 매칭
            for request in requests {
                if let storedNoteId = request.content.userInfo["noteId"] as? String,
                   storedNoteId == noteId,
                   let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let triggerDate = trigger.nextTriggerDate() {
                    
                    print("📅 userInfo에서 알림 발견: \(noteId)")
                    DispatchQueue.main.async {
                        completion(true, triggerDate, request.content.title)
                    }
                    return
                }
            }
            
            print("📅 알림을 찾을 수 없음: \(noteId)")
            DispatchQueue.main.async {
                completion(false, nil, nil)
            }
        }
    }
    
    // 디버깅: 모든 예약된 알림 출력
    func printAllScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📅 현재 예약된 알림 개수: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    print("📅 - 알림 ID: \(request.identifier), 시간: \(date), 제목: \(request.content.title)")
                    
                    if let noteId = request.content.userInfo["noteId"] as? String {
                        print("📅   노트 ID(userInfo): \(noteId)")
                    }
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
