import Domain
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

extension AuthClient {
    public static var live: Self {
        Self(
            currentUser: {
                guard let nativeUser = Auth.auth().currentUser else {
                    return nil
                }

                return Domain.User(
                    id: nativeUser.uid,
                    email: nativeUser.email ?? "",
                    name: nativeUser.displayName ?? "사용자",
                    imageURL: nativeUser.photoURL,
                    createdAt: Date(),
                    updatedAt: Date(),
                    loginProvider: .google // TODO: 실제 로그인 시 발급받은 제공자 처리 필요
                )
            },
            login: { provider in
                switch provider {
                case .google:
                    return try await googleSignIn()
                case .apple:
                    // TODO: Apple 로그인 레거시 구현체 추가 필요 (Service/AuthService.swift 참고)
                    throw AuthError.invalidProvider
                }
            },
            logout: {
                try Auth.auth().signOut()
            },
            deleteAccount: {
                if let user = Auth.auth().currentUser {
                    try await user.delete()
                }
            }
        )
    }

    @MainActor
    private static func googleSignIn() async throws -> Domain.User {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            throw AuthError.unknown
        }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.unknown
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.unknown
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        let nativeUser = authResult.user

        return Domain.User(
            id: nativeUser.uid,
            email: nativeUser.email ?? "",
            name: nativeUser.displayName ?? "사용자",
            imageURL: nativeUser.photoURL,
            createdAt: Date(),
            updatedAt: Date(),
            loginProvider: .google
        )
    }
}
