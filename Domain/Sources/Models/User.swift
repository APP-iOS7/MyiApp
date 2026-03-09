import Foundation

public struct User {
    public let id: String
    public let email: String
    public let name: String
    public let imageURL: URL?
    public let createdAt: Date
    public let updatedAt: Date
    public let loginProvider: LoginProvider

    public init(
        id: String,
        email: String,
        name: String,
        imageURL: URL? = nil,
        createdAt: Date,
        updatedAt: Date,
        loginProvider: LoginProvider
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.loginProvider = loginProvider
    }
}
