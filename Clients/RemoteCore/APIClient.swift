import Foundation

/// Thin URLSession wrapper that:
/// - prefixes the configured base URL,
/// - attaches the current JWT (if any) as `Authorization: Bearer ...`,
/// - encodes/decodes JSON via `APIConfig`,
/// - maps HTTP status codes onto `APIError`.
public actor APIClient {

    public static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL

    public init(baseURL: URL = APIConfig.baseURL) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.baseURL = baseURL
    }

    // MARK: - Public verbs

    public func get<T: Decodable & Sendable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        try await send(method: "GET", path: path, query: query, body: noBody)
    }

    public func postJSON<U: Encodable & Sendable, T: Decodable & Sendable>(_ path: String, body: U) async throws -> T {
        try await send(method: "POST", path: path, body: body)
    }

    public func postEmpty<T: Decodable & Sendable>(_ path: String) async throws -> T {
        try await send(method: "POST", path: path, body: noBody)
    }

    public func postNoResponse<U: Encodable & Sendable>(_ path: String, body: U) async throws {
        let _: NoContent = try await send(method: "POST", path: path, body: body)
    }

    public func patch<U: Encodable & Sendable, T: Decodable & Sendable>(_ path: String, body: U) async throws -> T {
        try await send(method: "PATCH", path: path, body: body)
    }

    public func deleteEmpty(_ path: String) async throws {
        let _: NoContent = try await send(method: "DELETE", path: path, body: noBody)
    }

    // MARK: - Internals

    private func send<U: Encodable, T: Decodable>(
        method: String,
        path: String,
        query: [String: String] = [:],
        body: U?
    ) async throws -> T {
        let request = try buildRequest(method: method, path: path, query: query, body: body)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error.localizedDescription)
        }
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unexpected("non-http response")
        }
        try checkStatus(http: http, body: data)

        if T.self == NoContent.self {
            return NoContent() as! T
        }
        guard !data.isEmpty else {
            throw APIError.decoding("empty body where \(T.self) expected")
        }
        do {
            return try APIConfig.jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(String(describing: error))
        }
    }

    private func buildRequest<U: Encodable>(
        method: String, path: String, query: [String: String], body: U?
    ) throws -> URLRequest {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else {
            throw APIError.unexpected("bad url path: \(path)")
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenStore.load() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body, !(body is NoBody) {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                req.httpBody = try APIConfig.jsonEncoder.encode(body)
            } catch {
                throw APIError.unexpected("encode failed: \(error)")
            }
        }
        return req
    }

    private func checkStatus(http: HTTPURLResponse, body: Data) throws {
        switch http.statusCode {
        case 200..<300: return
        case 400: throw APIError.badRequest(String(data: body, encoding: .utf8))
        case 401:
            // Server rejected our JWT — clear local state.
            AuthState.shared.update(session: nil, accessToken: nil)
            throw APIError.unauthorized
        case 403: throw APIError.forbidden
        case 404: throw APIError.notFound
        case 409: throw APIError.conflict
        case 500..<600: throw APIError.server(http.statusCode, String(data: body, encoding: .utf8))
        default: throw APIError.unexpected("status \(http.statusCode)")
        }
    }

    private var noBody: NoBody? { nil }
}

/// Sentinel marker for body-less requests.
struct NoBody: Encodable, Sendable {}

/// Sentinel marker for "we don't care about the response body" calls.
public struct NoContent: Decodable, Sendable {
    public init() {}
    public init(from decoder: Decoder) throws {}
}
