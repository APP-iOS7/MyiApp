//
//  AuthService.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User?
    private let auth: Auth = Auth.auth()
    static let shared = AuthService()
    
    private init() {
        user = auth.currentUser
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        self.user = result.user
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        self.user = result.user
    }
    
    func signOut() {
        try? auth.signOut()
        self.user = nil
    }
    
}
