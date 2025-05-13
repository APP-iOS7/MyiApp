//
//  VoiceRecordViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import Combine
import AVFoundation
import Accelerate

enum CryAnalysisStep {
    case start
    case processing
    case result(EmotionResult)
}

class VoiceRecordViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var engine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?

    @Published var audioLevels: [Float] = Array(repeating: 0.5, count: 12) // 이퀄라이저에서 사용할 오디오 레벨 배열 (초기값 0.5)
    @Published var step: CryAnalysisStep = .start

    // 오디오 측정을 시작하는 함수
    func startAudioMonitoring() {
        engine = AVAudioEngine()
        guard let engine = engine else { return }
        inputNode = engine.inputNode

        let format = inputNode!.outputFormat(forBus: 0)
        inputNode!.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
            let magnitudes = self.fftFromBuffer(buffer)
            print("🎙️ magnitudes:", magnitudes) // 로그 추가
            DispatchQueue.main.async {
                self.audioLevels = magnitudes
            }
        }

        do {
            try engine.start()
            print("🎧 AVAudioEngine 시작됨") // 로그 추가
        } catch {
            print("AVAudioEngine start 실패: \(error.localizedDescription)")
        }
    }

    // FFT 분석 및 주파수별 magnitude 계산 함수 (실제 buffer 접근 필요, AVAudioEngine 필요)
    private func fftFromBuffer(_ buffer: AVAudioPCMBuffer) -> [Float] {
        let frameCount = Int(buffer.frameLength)
        let log2n = vDSP_Length(log2(Float(frameCount)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return []
        }

        let channels = buffer.floatChannelData!
        let channelData = channels[0]
        var window = [Float](repeating: 0, count: frameCount)
        vDSP_hann_window(&window, vDSP_Length(frameCount), Int32(vDSP_HANN_NORM))
        var windowedSignal = [Float](repeating: 0, count: frameCount)
        vDSP_vmul(channelData, 1, window, 1, &windowedSignal, 1, vDSP_Length(frameCount))

        var real = [Float](repeating: 0, count: frameCount/2)
        var imag = [Float](repeating: 0, count: frameCount/2)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)

        windowedSignal.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: frameCount) {
                vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
            }
        }

        vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        var magnitudes = [Float](repeating: 0.0, count: frameCount / 2)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))

        var normalizedMagnitudes = [Float](repeating: 0.0, count: audioLevels.count)
        let step = magnitudes.count / audioLevels.count
        for i in 0..<audioLevels.count {
            let start = i * step
            let end = start + step
            let avg = magnitudes[start..<min(end, magnitudes.count)].reduce(0, +) / Float(step)
            let scaled = pow(avg, 0.5) / 5000.0
            normalizedMagnitudes[i] = min(1.0, scaled)
        }

        vDSP_destroy_fftsetup(fftSetup)
        return normalizedMagnitudes
    }

    func stopAudioMonitoring() {
        inputNode?.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        inputNode = nil
    }

    func cancel() {
        stopAudioMonitoring()
        step = .start
    }

    func startAnalysis() {
        step = .processing
    }
}
