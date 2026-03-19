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
            login: { _ in
                // 시뮬레이션을 위해 1초 대기 후 성공 응답 반환
                try await Task.sleep(nanoseconds: 1_000_000_000)

                return User(
                    id: "dummy_uid",
                    email: "test@example.com",
                    name: "테스트 사용자",
                    imageURL: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    loginProvider: .google
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
