import Foundation

public struct AuthClient: Sendable {
    public var current: @Sendable () -> Session?
    public var stateStream: @Sendable () -> AsyncStream<Session?>
    public var signInWithApple: @Sendable () async throws -> Session
    public var signInWithGoogle: @Sendable () async throws -> Session
    public var signOut: @Sendable () async throws -> Void
    public var deleteAccount: @Sendable () async throws -> Void

    public init(
        current: @escaping @Sendable () -> Session?,
        stateStream: @escaping @Sendable () -> AsyncStream<Session?>,
        signInWithApple: @escaping @Sendable () async throws -> Session,
        signInWithGoogle: @escaping @Sendable () async throws -> Session,
        signOut: @escaping @Sendable () async throws -> Void,
        deleteAccount: @escaping @Sendable () async throws -> Void
    ) {
        self.current = current
        self.stateStream = stateStream
        self.signInWithApple = signInWithApple
        self.signInWithGoogle = signInWithGoogle
        self.signOut = signOut
        self.deleteAccount = deleteAccount
    }
}
