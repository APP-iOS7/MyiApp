import Foundation

public enum APIError: Error, Sendable {
    case unauthorized              // 401
    case forbidden                 // 403
    case notFound                  // 404
    case conflict                  // 409
    case badRequest(String?)       // 400
    case server(Int, String?)      // 5xx
    case decoding(String)
    case network(String)
    case unexpected(String?)
}
