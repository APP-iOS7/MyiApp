import ComposableArchitecture
import Domain
import Foundation

extension AuthClient: @retroactive TestDependencyKey {}
extension AuthClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        current: {
            AuthState.shared.snapshot()
        },
        stateStream: {
            AuthState.shared.stream()
        },
        signInWithApple: { @Sendable () async throws(AuthError) -> Session? in
            do {
                let provider = await AppleSignInProvider()
                let appleResult = try await provider.signIn()

                AppleAuthorizationCodeStore.save(appleResult.authorizationCode)

                let response: LoginResponseDTO = try await APIClient.shared.postJSON(
                    "/auth/login/apple",
                    body: LoginRequestDTO(idToken: appleResult.identityToken)
                )

                let session = Session(
                    uid: response.userId,
                    email: nil,
                    providerIDs: ["apple.com"]
                )
                AuthState.shared.update(session: session, accessToken: response.accessToken)
                return session
            } catch AppleSignInError.userCancelled {
                return nil
            } catch {
                throw AuthError.unexpected
            }
        },
        signInWithGoogle: { @Sendable () async throws(AuthError) -> Session? in
            do {
                let googleResult = try await GoogleSignInProvider.signIn()

                let response: LoginResponseDTO = try await APIClient.shared.postJSON(
                    "/auth/login/google",
                    body: LoginRequestDTO(idToken: googleResult.idToken)
                )

                let session = Session(
                    uid: response.userId,
                    email: nil,
                    providerIDs: ["google.com"]
                )
                AuthState.shared.update(session: session, accessToken: response.accessToken)
                return session
            } catch GoogleSignInError.userCancelled {
                return nil
            } catch {
                throw AuthError.unexpected
            }
        },
        signOut: { @Sendable () async throws(AuthError) in
            AuthState.shared.update(session: nil, accessToken: nil)
            AppleAuthorizationCodeStore.delete()
        },
        deleteAccount: { @Sendable () async throws(AuthError) in
            // TODO: wire to backend `DELETE /me` once that endpoint exists.
            // For now, behave like sign-out so the UI doesn't loop.
            AuthState.shared.update(session: nil, accessToken: nil)
            AppleAuthorizationCodeStore.delete()
        }
    )
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
