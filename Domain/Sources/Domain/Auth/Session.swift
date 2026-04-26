import Foundation

public struct Session: Equatable, Hashable, Sendable {
    public let uid: String
    public var email: String
    public var displayName: String
    public var photoURL: URL?
    public var providerID: String
    public var createdAt: Date

    public init(
        uid: String,
        email: String,
        displayName: String,
        photoURL: URL? = nil,
        providerID: String,
        createdAt: Date
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.providerID = providerID
        self.createdAt = createdAt
    }
}
