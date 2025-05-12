//
//  AuthService.swift
//  MyiApp
//
//  Created by Yung Hak Lee on 5/9/25.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import CryptoKit
import AuthenticationServices
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    @Published private(set) var user: User?
    private let auth: Auth = Auth.auth()
    static let shared = AuthService()
    private var currentNonce: String?
    
    private init() {
        self.user = auth.currentUser
    }
    
    // 로그아웃
    func signOut() {
        try? auth.signOut()
        self.user = nil
        DatabaseService.shared.hasBabyInfo = false
    }
    
    // 구글 로그인
    func googleSignIn() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active window scene"])
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID missing"])
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: result.user.accessToken.tokenString)
        let authResult = try await auth.signIn(with: credential)
        self.user = authResult.user
        print("Firebase user: \(authResult.user.uid)")
    }
    
    // 애플 로그인
    func appleSignIn(_ authorization: ASAuthorization) async throws {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])
            }
            guard let nonce = currentNonce else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Nonce is missing"])
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Apple ID token"])
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode ID token"])
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            let authResult = try await auth.signIn(with: credential)
            self.user = authResult.user
            self.currentNonce = nil
            print("Firebase user: \(authResult.user.uid)")
        }
    }
    
    // Apple 로그인 요청 설정
        func configureAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
            let nonce = randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(nonce)
            print("Generated Nonce: \(nonce)")
        }
    // Nonce 생성
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }
      return String(nonce)
    }
    
    // sha256 해시
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()
      return hashString
    }
}
