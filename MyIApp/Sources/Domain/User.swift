import Foundation

struct User: Equatable, Identifiable {
    let id: String
    let name: String
    let email: String
    let profileImageURL: URL?
    let createdAt: Date
    let updatedAt: Date
}
