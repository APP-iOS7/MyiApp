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
                    .task { await updateAppState() }
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
                .background(Color.white.ignoresSafeArea())
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
