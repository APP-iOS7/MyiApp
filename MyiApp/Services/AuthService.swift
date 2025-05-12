//
//  AuthService.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/9/25.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User?
    private let auth: Auth = Auth.auth()
    static let shared = AuthService()
    
    private init() {
        self.user = auth.currentUser
    }
    
    // 이메일 회원 가입
    func signUp(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        self.user = result.user
    }
    
    // 로그인
    func signIn(email: String, password: String) async throws {
        let result = try await auth.signIn(withEmail: email, password: password)
        self.user = result.user
    }
    
    // 로그아웃
    func signOut() {
        try? auth.signOut()
        self.user = nil
    }
    
    // 구글 로그인
    func googleSignIn() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: result.user.accessToken.tokenString)
        let authResult = try await auth.signIn(with: credential)
        self.user = authResult.user
    }
}
