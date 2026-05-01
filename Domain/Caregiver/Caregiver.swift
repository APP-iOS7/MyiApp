import Foundation

public struct Caregiver: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public var displayName: String?
    public var photoURL: URL?
    public var fcmToken: String?
    public var createdAt: Date

    public init(
        id: String,
        displayName: String? = nil,
        photoURL: URL? = nil,
        fcmToken: String? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.photoURL = photoURL
        self.fcmToken = fcmToken
        self.createdAt = createdAt
    }
}
