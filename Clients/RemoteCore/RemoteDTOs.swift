import Foundation

// MARK: - Auth

public struct LoginRequestDTO: Encodable, Sendable {
    public let idToken: String
    public init(idToken: String) { self.idToken = idToken }
}

public struct LoginResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let userId: String
    public let expiresIn: Int
}

public struct MeResponseDTO: Decodable, Sendable {
    public let id: String
    public let provider: String
    public let displayName: String?
    public let email: String?
    public let createdAt: Date?
}

// MARK: - Devices

public struct RegisterDeviceRequestDTO: Encodable, Sendable {
    public let token: String
    public let environment: String  // "sandbox" | "production"
}

// MARK: - Storage / Uploads

public enum UploadKindDTO: String, Encodable, Sendable {
    case profile
    case noteImage
    case cryAudio
}

public struct PresignedUploadRequestDTO: Encodable, Sendable {
    public let kind: UploadKindDTO
    public let contentType: String
}

public struct PresignedUploadResponseDTO: Decodable, Sendable {
    public let uploadUrl: String
    public let key: String
    public let expiresAt: Date
}

// MARK: - Generic SSE event envelope

public struct SSEEventEnvelope: Decodable, Sendable {
    public let type: String
    public let babyId: String
    public let actorId: String?
    public let timestamp: Date?
}
