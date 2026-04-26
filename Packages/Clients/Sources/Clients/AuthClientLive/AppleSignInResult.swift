import Foundation

struct AppleSignInResult {
    let identityToken: String
    let rawNonce: String
    let fullName: PersonNameComponents?
    let email: String?
}
