import Foundation

public struct AuthClient: Sendable {
    public var currentUser: @Sendable () async throws -> User?
    public var login: @Sendable (LoginProvider) async throws -> User
    public var logout: @Sendable () async throws -> Void
    public var deleteAccount: @Sendable () async throws -> Void

    public init(
        currentUser: @escaping @Sendable () async throws -> User?,
        login: @escaping @Sendable (LoginProvider) async throws -> User,
        logout: @escaping @Sendable () async throws -> Void,
        deleteAccount: @escaping @Sendable () async throws -> Void
    ) {
        self.currentUser = currentUser
        self.login = login
        self.logout = logout
        self.deleteAccount = deleteAccount
    }
}
