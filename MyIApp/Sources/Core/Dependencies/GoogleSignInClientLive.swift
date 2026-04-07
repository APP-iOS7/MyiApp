import ComposableArchitecture
import FirebaseCore
import GoogleSignIn
import UIKit

extension GoogleSignInClient: DependencyKey {
    static let liveValue: GoogleSignInClient = .init(
        signIn: {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw GoogleSignInError.missingClientID
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = await windowScene.windows.first,
                  let rootViewController = await window.rootViewController
            else {
                throw GoogleSignInError.missingRootViewController
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw GoogleSignInError.missingIDToken
            }

            let accessToken = result.user.accessToken.tokenString

            return .google(idToken: idToken, accessToken: accessToken)
        }
    )
}

extension DependencyValues {
    var googleSignInClient: GoogleSignInClient {
        get { self[GoogleSignInClient.self] }
        set { self[GoogleSignInClient.self] = newValue }
    }
}

enum GoogleSignInError: Error {
    case missingClientID
    case missingRootViewController
    case missingIDToken
}
