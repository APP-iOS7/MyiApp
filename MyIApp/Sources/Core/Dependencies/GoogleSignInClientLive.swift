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

            let result = try await performGoogleSignIn(clientID: clientID)
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

@MainActor
private func performGoogleSignIn(clientID: String) async throws -> GIDSignInResult {
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

    let rootViewController = try rootViewController()
    return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
}

@MainActor
private func rootViewController() throws -> UIViewController {
    guard let rootViewController = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)?
        .rootViewController
    else {
        throw GoogleSignInError.missingRootViewController
    }

    return topMostViewController(from: rootViewController)
}

@MainActor
private func topMostViewController(from viewController: UIViewController) -> UIViewController {
    guard let presentedViewController = viewController.presentedViewController else {
        return viewController
    }

    return topMostViewController(from: presentedViewController)
}
