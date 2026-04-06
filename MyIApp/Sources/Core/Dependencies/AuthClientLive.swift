import ComposableArchitecture
import FirebaseAuth
import Foundation

extension AuthClient: DependencyKey {
    static let liveValue: AuthClient = .init(
        currentSession: {
            guard let user = Auth.auth().currentUser else {
                return nil
            }

            let provider: OAuthProvider
            switch user.providerData.first?.providerID {
            case "apple.com":
                provider = .apple
            case "google.com":
                provider = .google
            default:
                return nil
            }
            return Session(userID: user.uid, provider: provider)
        },
        signIn: { credential in
            let authCredential: AuthCredential
            let oAuthProvider: OAuthProvider
            switch credential {
            case let .apple(idToken: idToken, nonce: nonce, givenName: givenName, familyName: familyName):
                authCredential = FirebaseAuth.OAuthProvider.appleCredential(
                    withIDToken: idToken,
                    rawNonce: nonce,
                    fullName: PersonNameComponents(givenName: givenName, familyName: familyName)
                )
                oAuthProvider = .apple

            case let .google(idToken: idToken, accessToken: accessToken):
                authCredential = FirebaseAuth.GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )
                oAuthProvider = .google
            }

            let result = try await Auth.auth().signIn(with: authCredential)
            return Session(userID: result.user.uid, provider: oAuthProvider)
        },
        signOut: {
            try Auth.auth().signOut()
        }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
