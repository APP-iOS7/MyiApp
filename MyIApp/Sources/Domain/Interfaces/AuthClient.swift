import Foundation

struct AuthClient {
    var currentSession: @Sendable () async -> Session?
    var signIn: @Sendable (OAuthCredential) async throws -> Session
    var signOut: @Sendable () async throws -> Void
}
