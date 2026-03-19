import Domain
import FirebaseAuth
import Foundation

extension AuthClient {
    public static var live: Self {
        Self(
            currentUser: {
                guard let nativeUser = Auth.auth().currentUser else {
                    return nil
                }

                return User(
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
                // 현실적인 'Live' 구현을 위해 signInAnonymously()를 통해 실제 Firebase 세션을 생성합니다.
                // 실제 Google/Apple 로그인은 플랫폼별 ID 토큰 취득 후 signIn(with: credential) 호출이 필요합니다.
                let result = try await Auth.auth().signInAnonymously()
                let nativeUser = result.user

                return User(
                    id: nativeUser.uid,
                    email: nativeUser.email ?? "",
                    name: nativeUser.displayName ?? "사용자",
                    imageURL: nativeUser.photoURL,
                    createdAt: Date(),
                    updatedAt: Date(),
                    loginProvider: provider
                )
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
}
