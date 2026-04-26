import ComposableArchitecture
import Domain

extension AuthClient {
    public static let liveValue = Self(
        current: { fatalError("Unimplemented") },
        stateStream: { fatalError("Unimplemented") },
        signInWithApple: { fatalError("Unimplemented") },
        signInWithGoogle: { fatalError("Unimplemented") },
        signOut: { fatalError("Unimplemented") },
        deleteAccount: { fatalError("Unimplemented") }
    )
}
