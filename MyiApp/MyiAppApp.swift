//
//  MyiAppApp.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MyiAppApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authService.user == nil {
                    TestLogInView()
                } else {
                    ContentView()
                }
            }
        }
    }
}
