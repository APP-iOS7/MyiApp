import Foundation
import Network
import Testing

/// Firebase 에뮬레이터가 실행 중인지 확인하는 유틸리티입니다.
enum FirebaseEmulatorCheck {
    private final class ResponseState: @unchecked Sendable {
        private var _hasResponded = false
        private let lock = NSLock()

        var hasResponded: Bool {
            self.lock.lock()
            defer { lock.unlock() }
            return self._hasResponded
        }

        func setResponded() -> Bool {
            self.lock.lock()
            defer { lock.unlock() }
            if !self._hasResponded {
                self._hasResponded = true
                return true
            }
            return false
        }
    }

    static func isPortOpen(_ port: Int) async -> Bool {
        let host = NWEndpoint.Host("127.0.0.1")
        let endpoint = NWEndpoint.Port(rawValue: UInt16(port))!
        let connection = NWConnection(host: host, port: endpoint, using: .tcp)
        let state = ResponseState()

        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            connection.stateUpdateHandler = { (connectionState: NWConnection.State) in
                switch connectionState {
                case .ready:
                    if state.setResponded() {
                        continuation.resume(returning: true)
                        connection.cancel()
                    }

                case .waiting(_),
                     .failed:
                    if state.setResponded() {
                        continuation.resume(returning: false)
                        connection.cancel()
                    }

                default:
                    break
                }
            }

            connection.start(queue: .global())

            // 타임아웃 설정 (0.5초)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if state.setResponded() {
                    continuation.resume(returning: false)
                    connection.cancel()
                }
            }
        }
    }

    /// Firestore 에뮬레이터(8080) 실행 여부
    static func isFirestoreEmulatorRunning() async -> Bool {
        await self.isPortOpen(8080)
    }

    /// Auth 에뮬레이터(9099) 실행 여부
    static func isAuthEmulatorRunning() async -> Bool {
        await self.isPortOpen(9099)
    }
}
