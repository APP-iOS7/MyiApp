import Domain
import Foundation
import os

/// Process-wide auth state. Holds the current `Session` and broadcasts changes
/// to subscribers via `AsyncStream`. The JWT itself lives in the Keychain via
/// `TokenStore`; this class merely keeps the high-level `Session?` snapshot.
public final class AuthState: @unchecked Sendable {

    public static let shared = AuthState()

    private struct State {
        var session: Session?
        var subscribers: [UUID: AsyncStream<Session?>.Continuation] = [:]
    }

    private let lock = OSAllocatedUnfairLock<State>(initialState: State())

    public func snapshot() -> Session? {
        lock.withLock { $0.session }
    }

    public func token() -> String? {
        TokenStore.load()
    }

    public func update(session: Session?, accessToken: String?) {
        if let token = accessToken {
            TokenStore.save(token)
        }
        if session == nil {
            TokenStore.delete()
        }
        let conts = lock.withLock { state -> [AsyncStream<Session?>.Continuation] in
            state.session = session
            return Array(state.subscribers.values)
        }
        for cont in conts {
            cont.yield(session)
        }
    }

    public func stream() -> AsyncStream<Session?> {
        AsyncStream { cont in
            let id = UUID()
            let initial = lock.withLock { state -> Session? in
                state.subscribers[id] = cont
                return state.session
            }
            cont.yield(initial)
            cont.onTermination = { [weak self] _ in
                guard let self else { return }
                self.lock.withLock { state in
                    _ = state.subscribers.removeValue(forKey: id)
                }
            }
        }
    }
}
