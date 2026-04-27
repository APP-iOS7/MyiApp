import CryptoKit
import Foundation

enum Nonce {
    static func random(length: Int = 32) throws(NonceError) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard status == errSecSuccess else {
            throw NonceError.randomGenerationFailed(status: status)
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { charset[Int($0) % charset.count] }

        return String(nonce)
    }

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)

        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum NonceError: LocalizedError {
    case randomGenerationFailed(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case let .randomGenerationFailed(status):
            "nonce 생성 실패 (OSStatus: \(status))"
        }
    }
}
