import Domain
import Foundation

extension AuthClient {
    public static let previewValue = Self(
        current: { .preview },
        stateStream: {
            AsyncStream { continuation in
                continuation.yield(.preview)
            }
        },
        signInWithApple: { .preview },
        signInWithGoogle: { .preview },
        signOut: {},
        deleteAccount: {}
    )
}

private extension Session {
    static let preview = Session(
        uid: "preview-uid",
        email: "preview@example.com",
        displayName: "Preview User",
        photoURL: nil,
        providerIDs: ["apple.com"],
        createdAt: .distantPast
    )
}
