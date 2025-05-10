//
//  AuthService.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class AuthService: ObservableObject {
    @Published private(set) var user: User?
    private let auth: Auth = Auth.auth()
    static let shared = AuthService()
    
    private init() {
        user = auth.currentUser
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch {
            print(error)
        }
        self.user = nil
    }
    
    @MainActor
    func googleSignIn() async throws {
        guard let clientID = auth.app?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else { return }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else { return }
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let dataResult = try await auth.signIn(with: credential)
        self.user = dataResult.user
    }
    
}
