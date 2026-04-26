import Foundation

public struct Session: Equatable, Hashable, Sendable {
    public let uid: String
    public var email: String?
    public var displayName: String?
    public var photoURL: URL?
    public var providerIDs: [String]
    public var createdAt: Date

    public init(
        uid: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil,
        providerIDs: [String],
        createdAt: Date
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.providerIDs = providerIDs
        self.createdAt = createdAt
    }
}
