//
//  MyiApp.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // 알림 설정
        UNUserNotificationCenter.current().delegate = self
        
        // 알림 권한 상태 확인
        NotificationService.shared.checkAuthorizationStatus()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // 앱이 포그라운드 상태일 때 알림을 표시하기 위한 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // 알림을 탭했을 때 처리할 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 탭한 알림의 식별자를 가져와서 필요한 액션 수행
        let noteId = response.notification.request.identifier
        print("알림 탭됨: \(noteId)")
        
        // 여기서 필요하다면 알림을 탭했을 때 특정 화면으로 이동하는 코드를 추가할 수 있음
        
        completionHandler()
    }
}

enum AppState {
    case loading
    case login
    case content
    case register
}

@main
struct MyiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authService = AuthService.shared
    @StateObject var databaseService = DatabaseService.shared
    @State private var appState: AppState = .loading
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                currentView
                    .task {
                        await updateAppState()
                        await AccountSettingsViewModel.shared.loadProfile()
                    }
                    .onChange(of: authService.user) { _, _ in
                        Task { await updateAppState() }
                    }
                    .onChange(of: databaseService.hasBabyInfo) { _, newValue in
                        if newValue == true {
                            appState = .content
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private var currentView: some View {
        switch appState {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.customBackground.ignoresSafeArea())
            case .login:
                LogInView()
            case .content:
                ContentView()
            case .register:
                RegisterBabyView()
        }
    }
    
    @MainActor
    private func updateAppState() async {
        appState = authService.user == nil ? .login : await databaseService.checkBabyInfo() ? .content : .register
        databaseService.hasBabyInfo = appState != .login ? databaseService.hasBabyInfo : false
    }
}
