#if DEBUG
    import ConcurrencyExtras
    import Domain
    import Foundation

    extension AudioRecorderClient {
        public static var previewValue: Self {
            let isRecording = LockIsolated(false)
            return Self(
                requestPermission: { @Sendable in true },
                startRecording: { @Sendable _ async throws(AudioRecorderError) in
                    isRecording.setValue(true)
                },
                stopRecording: { @Sendable in
                    isRecording.setValue(false)
                },
                cancelRecording: { @Sendable in
                    isRecording.setValue(false)
                },
                currentVolume: { @Sendable in
                    isRecording.value ? Float.random(in: 0.1 ... 0.9) : nil
                }
            )
        }
    }
#endif
