//
//  MyiApp.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct MyiApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authService = AuthService.shared
    @StateObject var databaseService = DatabaseService.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    if authService.user == nil {
                        TestLogInView()
                    } else if !databaseService.hasBabyInfo {
                        TestRegisterBabyView()
                    } else {
                        ContentView()
                    }
                }
            }
        }
    }
}
