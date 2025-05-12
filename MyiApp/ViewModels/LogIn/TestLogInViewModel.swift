//
//  TestLogInViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation

@MainActor
class TestLogInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: String?
    private let authService: AuthService
    
    init() {
        self.authService = AuthService.shared
    }

    func signInWithGoogle() {
        Task {
            do {
                try await authService.googleSignIn()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
