import Foundation

struct GoogleSignInClient {
    var signIn: @Sendable () async throws -> OAuthCredential
}
