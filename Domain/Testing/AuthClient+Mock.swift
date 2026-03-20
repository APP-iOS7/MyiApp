import Domain
import Foundation

extension User {
    public static var mock: Self {
        User(
            id: "mock_user_id",
            email: "mock@example.com",
            name: "Mock User",
            createdAt: Date(),
            updatedAt: Date(),
            loginProvider: .google
        )
    }
}

extension AuthClient {
    public static var mock: Self {
        AuthClient(
            currentUser: { () throws(AuthError) in .mock },
            login: { _ throws(AuthError) in .mock },
            logout: { () throws(AuthError) in },
            deleteAccount: { () throws(AuthError) in }
        )
    }

    public static func failing(error: AuthError) -> Self {
        AuthClient(
            currentUser: { () throws(AuthError) in throw error },
            login: { _ throws(AuthError) in throw error },
            logout: { () throws(AuthError) in throw error },
            deleteAccount: { () throws(AuthError) in throw error }
        )
    }
}
