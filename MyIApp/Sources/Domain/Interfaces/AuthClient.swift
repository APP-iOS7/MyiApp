import Foundation

struct AuthClient {
    var currentSession: @Sendable () async -> Session?
    var signIn: @Sendable () async throws -> Session
    var signOut: @Sendable () async throws -> Void
}
