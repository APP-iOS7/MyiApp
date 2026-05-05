import Foundation

public struct SSEEvent: Sendable {
    public let name: String
    public let data: String
}

/// Minimal Server-Sent Events client backed by URLSession's async byte stream.
///
/// The stream finishes on disconnection or task cancellation. Callers are
/// responsible for reconnecting with backoff if they want a long-lived feed.
public final class SSEClient: Sendable {

    public init() {}

    public func events(path: String) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var req = URLRequest(url: APIConfig.baseURL.appendingPathComponent(path))
                    req.httpMethod = "GET"
                    req.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    req.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
                    if let token = TokenStore.load() {
                        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    }
                    req.timeoutInterval = .infinity

                    let config = URLSessionConfiguration.default
                    config.timeoutIntervalForRequest = .infinity
                    config.timeoutIntervalForResource = .infinity
                    let session = URLSession(configuration: config)

                    let (bytes, response) = try await session.bytes(for: req)
                    guard let http = response as? HTTPURLResponse else {
                        continuation.finish(throwing: APIError.unexpected("non-http response"))
                        return
                    }
                    guard http.statusCode == 200 else {
                        if http.statusCode == 401 {
                            AuthState.shared.update(session: nil, accessToken: nil)
                            continuation.finish(throwing: APIError.unauthorized)
                        } else {
                            continuation.finish(throwing: APIError.unexpected("SSE status \(http.statusCode)"))
                        }
                        return
                    }

                    var eventName = "message"
                    var dataLines: [String] = []

                    for try await rawLine in bytes.lines {
                        try Task.checkCancellation()
                        if rawLine.isEmpty {
                            // Dispatch buffered event.
                            if !dataLines.isEmpty {
                                continuation.yield(SSEEvent(name: eventName, data: dataLines.joined(separator: "\n")))
                            }
                            eventName = "message"
                            dataLines.removeAll()
                            continue
                        }
                        if rawLine.hasPrefix(":") {
                            // Comment / heartbeat.
                            continue
                        }
                        if rawLine.hasPrefix("event:") {
                            eventName = String(rawLine.dropFirst("event:".count)).trimmingCharacters(in: .whitespaces)
                        } else if rawLine.hasPrefix("data:") {
                            let part = String(rawLine.dropFirst("data:".count))
                            // SSE permits a single space after "data:".
                            let trimmed = part.hasPrefix(" ") ? String(part.dropFirst()) : part
                            dataLines.append(trimmed)
                        }
                        // Other fields (id:, retry:) ignored for now.
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
