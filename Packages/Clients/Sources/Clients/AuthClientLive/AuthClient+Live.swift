import Domain
@preconcurrency import FirebaseAuth
import Foundation

extension AuthClient {
    public static let liveValue = Self(
        current: {
            Auth.auth().currentUser.map(Session.init(user:))
        },
        stateStream: {
            AsyncStream { continuation in
                let handle = Auth.auth().addStateDidChangeListener { _, user in
                    continuation.yield(user.map(Session.init(user:)))
                }
                continuation.onTermination = { _ in
                    Auth.auth().removeStateDidChangeListener(handle)
                }
            }
        },
        signInWithApple: {
            let provider = await AppleSignInProvider()
            let appleResult = try await provider.signIn()

            let credential = OAuthProvider.appleCredential(
                withIDToken: appleResult.identityToken,
                rawNonce: appleResult.rawNonce,
                fullName: appleResult.fullName
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            return Session(user: authResult.user)
        },
        signInWithGoogle: {
            let googleResult = try await GoogleSignInProvider.signIn()

            let credential = GoogleAuthProvider.credential(
                withIDToken: googleResult.idToken,
                accessToken: googleResult.accessToken
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            return Session(user: authResult.user)
        },
        signOut: {
            try Auth.auth().signOut()
        },
        deleteAccount: { fatalError("Unimplemented") }
    )
}

extension Session {
    fileprivate init(user: User) {
        self.init(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL,
            providerIDs: user.providerData.map(\.providerID),
            createdAt: user.metadata.creationDate ?? Date()
        )
    }
}
