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
    
    private var notificationCache: [String: (date: Date, title: String)] = [:]
    
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
                }
                completion(granted)
            }
        }
    }
    
    // 알림 예약
    @discardableResult
    func scheduleNotification(for note: Note, minutesBefore: Int = 0) -> (success: Bool, time: Date?, message: String?) {
        
        if authorizationStatus != .authorized {
            return (false, nil, "알림 권한이 필요합니다")
        }
        
        cancelNotification(with: note.id.uuidString)
        
        let triggerDate = minutesBefore == 0 ?
            note.date :
            note.date.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        
        if triggerDate <= Date() {
            return (false, nil, "이미 지난 시간으로 알림을 설정할 수 없습니다.")
        }
        
        let content = UNMutableNotificationContent()
        content.title = "일정 알림"
        content.body = note.title
        content.sound = .default
        
        content.userInfo = [
            "noteId": note.id.uuidString,
            "title": note.title,
            "date": note.date.timeIntervalSince1970
        ]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        
        var isSuccessful = true
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().add(request) { error in
            defer { semaphore.signal() }
            
            if let error = error {
                isSuccessful = false
            } else {
            }
        }
        
        _ = semaphore.wait(timeout: .now() + 1.0)
        
        printAllScheduledNotifications()
        
        if isSuccessful {
            notificationCache[note.id.uuidString] = (triggerDate, note.title)
            return (true, triggerDate, nil)
        } else {
            return (false, nil, "알림 설정에 실패했습니다")
        }
    }
    
    func cancelNotification(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 캐시에서도 제거
        notificationCache.removeValue(forKey: identifier)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.printAllScheduledNotifications()
        }
    }
    
    func getNotificationTimeText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 a h:mm"
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: date)
    }
    
    func findNotificationForNote(noteId: String, completion: @escaping (Bool, Date?, String?) -> Void) {
        
        if let cached = notificationCache[noteId] {
            DispatchQueue.main.async {
                completion(true, cached.date, cached.title)
            }
            return
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            if let matchingRequest = requests.first(where: { $0.identifier == noteId }),
               let trigger = matchingRequest.trigger as? UNCalendarNotificationTrigger,
               let triggerDate = trigger.nextTriggerDate() {
                
                self.notificationCache[noteId] = (triggerDate, matchingRequest.content.title)
                
                DispatchQueue.main.async {
                    completion(true, triggerDate, matchingRequest.content.title)
                }
                return
            }
            
            for request in requests {
                if let storedNoteId = request.content.userInfo["noteId"] as? String,
                   storedNoteId == noteId,
                   let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let triggerDate = trigger.nextTriggerDate() {
                    
                    self.notificationCache[noteId] = (triggerDate, request.content.title)
                    
                    DispatchQueue.main.async {
                        completion(true, triggerDate, request.content.title)
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                completion(false, nil, nil)
            }
        }
    }
    
    func printAllScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    
                    if let noteId = request.content.userInfo["noteId"] as? String {
                        print("노트 ID(userInfo): \(noteId)")
                    }
                }
            }
        }
    }
    
    func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationCache.removeAll()

        printAllScheduledNotifications()
    }
    
    // 설정 앱의 알림 설정 화면 열기
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
