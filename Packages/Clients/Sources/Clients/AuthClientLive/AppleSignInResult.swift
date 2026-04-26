import Foundation

struct AppleSignInResult {
    let identityToken: String
    let authorizationCode: String
    let rawNonce: String
    let fullName: PersonNameComponents?
    let email: String?
}
