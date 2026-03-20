import Foundation

public struct AuthClient: Sendable {
    public var currentUser: @Sendable () async throws(AuthError) -> User?
    public var login: @Sendable (LoginProvider) async throws(AuthError) -> User
    public var logout: @Sendable () async throws(AuthError) -> Void
    public var deleteAccount: @Sendable () async throws(AuthError) -> Void

    public init(
        currentUser: @escaping @Sendable () async throws(AuthError) -> User?,
        login: @escaping @Sendable (LoginProvider) async throws(AuthError) -> User,
        logout: @escaping @Sendable () async throws(AuthError) -> Void,
        deleteAccount: @escaping @Sendable () async throws(AuthError) -> Void
    ) {
        self.currentUser = currentUser
        self.login = login
        self.logout = logout
        self.deleteAccount = deleteAccount
    }
}
