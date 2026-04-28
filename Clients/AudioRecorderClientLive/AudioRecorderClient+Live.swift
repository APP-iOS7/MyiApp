import AVFoundation
import ComposableArchitecture
import Domain
import Foundation

extension AudioRecorderClient: @retroactive TestDependencyKey {}
extension AudioRecorderClient: @retroactive DependencyKey {
    public static var liveValue: Self {
        let session = MicrophoneSession()
        return Self(
            requestPermission: {
                await AVAudioApplication.requestRecordPermission()
            },
            startRecording: { url in
                try await session.start(url: url)
            },
            stopRecording: {
                await session.stop()
            },
            cancelRecording: {
                await session.cancel()
            },
            currentVolume: {
                await session.currentVolume()
            }
        )
    }
}

public extension DependencyValues {
    var audioRecorderClient: AudioRecorderClient {
        get { self[AudioRecorderClient.self] }
        set { self[AudioRecorderClient.self] = newValue }
    }
}

private actor MicrophoneSession {
    private var recorder: AVAudioRecorder?

    func currentVolume() -> Float? {
        guard let recorder, recorder.isRecording else { return nil }
        recorder.updateMeters()
        let decibels = recorder.averagePower(forChannel: 0)
        guard decibels > -80 else { return 0 }
        return min(pow(10, decibels / 20) * 2, 1)
    }

    func start(url: URL) throws(AudioRecorderError) {
        guard recorder == nil else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)

            let recorder = try AVAudioRecorder(url: url, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ])
            recorder.isMeteringEnabled = true
            guard recorder.record() else {
                throw AudioRecorderError.engineFailed
            }
            self.recorder = recorder
        } catch {
            throw .engineFailed
        }
    }

    func stop() {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func cancel() {
        recorder?.stop()
        _ = recorder?.deleteRecording()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

