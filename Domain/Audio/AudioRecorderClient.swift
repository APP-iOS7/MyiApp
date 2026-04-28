import Foundation

public struct AudioRecorderClient: Sendable {
    public var requestPermission: @Sendable () async -> Bool
    public var startRecording: @Sendable (URL) async throws(AudioRecorderError) -> Void
    public var stopRecording: @Sendable () async -> Void
    public var cancelRecording: @Sendable () async -> Void
    public var currentVolume: @Sendable () async -> Float?

    public init(
        requestPermission: @escaping @Sendable () async -> Bool,
        startRecording: @escaping @Sendable (URL) async throws(AudioRecorderError) -> Void,
        stopRecording: @escaping @Sendable () async -> Void,
        cancelRecording: @escaping @Sendable () async -> Void,
        currentVolume: @escaping @Sendable () async -> Float?
    ) {
        self.requestPermission = requestPermission
        self.startRecording = startRecording
        self.stopRecording = stopRecording
        self.cancelRecording = cancelRecording
        self.currentVolume = currentVolume
    }
}
