import Foundation

public struct Session: Equatable, Hashable, Sendable {
    public let uid: String
    public var email: String?
    public var providerIDs: [String]

    public init(
        uid: String,
        email: String? = nil,
        providerIDs: [String]
    ) {
        self.uid = uid
        self.email = email
        self.providerIDs = providerIDs
    }
}
