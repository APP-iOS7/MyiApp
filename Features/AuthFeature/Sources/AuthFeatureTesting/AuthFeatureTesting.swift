import Domain
import Foundation

public enum AuthFeatureTesting {
    public static let mockUser = User(
        id: "mock-user-id",
        email: "test@example.com",
        name: "테스트 사용자",
        imageURL: nil,
        createdAt: Date(),
        updatedAt: Date(),
        loginProvider: .google
    )
}
