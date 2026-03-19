import Domain
import FirebaseAuth
import Foundation

extension AuthClient {
    public static var liveValue: Self {
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
            login: { _ in
                // 현재는 외부(Google SignIn 등)에서 인증 후 Firebase Credential을 얻어 로그인한다고 가정.
                // 일단 Dummy 구현체 또는 Error throw 처리
                struct NotYetImplemented: Error {}
                throw NotYetImplemented()
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
