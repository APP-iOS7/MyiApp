//
//  LogInViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import Foundation

@MainActor
class LogInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: String?
    private let authService: AuthService
    
    init() {
        self.authService = AuthService.shared
    }
    
    func signIn() async throws {
                try await authService.signIn(email: email, password: password)
    }
    
    func signUp() async throws {
                try await authService.signUp(email: email, password: password)
    }
    
    func signInWithGoogle() async throws {
            try await authService.googleSignIn()
        }
}
