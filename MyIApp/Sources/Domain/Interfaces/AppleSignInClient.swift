import Foundation

struct AppleSignInClient {
    var signIn: @Sendable () async throws -> OAuthCredential
}
