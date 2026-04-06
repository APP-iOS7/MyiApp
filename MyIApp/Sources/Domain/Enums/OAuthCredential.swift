import Foundation

enum OAuthCredential {
    case apple(idToken: String, nonce: String)
    case google(idToken: String, accessToken: String)
}
