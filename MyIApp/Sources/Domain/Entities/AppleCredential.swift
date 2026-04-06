import Foundation

struct AppleCredential: Equatable {
    let idToken: String
    let nonce: String
    let givenName: String?
    let familyName: String?
}
