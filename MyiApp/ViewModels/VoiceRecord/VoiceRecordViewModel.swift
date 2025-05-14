//
//  VoiceRecordViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import CoreML
import Combine
import AVFoundation
import Accelerate

enum CryAnalysisStep {
    case start
    case recording
    case processing
    case result(EmotionResult)
    case error(String)
}

class VoiceRecordViewModel: ObservableObject {
    private var engine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioSession: AVAudioSession?
    private var recordingBuffer: [Float] = []
    private var analysisTimer: Timer?

    private var converter: AVAudioConverter?
    private let outputSampleRate: Double = 22050.0

    // CoreML 모델 프로퍼티 추가
    private let model: DeepInfant_V2 = {
        do {
            return try DeepInfant_V2(configuration: MLModelConfiguration())
        } catch {
            fatalError("❌ CoreML 모델 로드 실패: \(error.localizedDescription)")
        }
    }()

    // 녹음 지속 시간 (7초)
    private let recordingDuration: TimeInterval = 7.0

    @Published var audioLevels: [Float] = Array(repeating: 0.0, count: 8) // EqualizerView의 막대 수와 일치
    @Published var step: CryAnalysisStep = .start
    @Published var recordingProgress: Double = 0.0
    
    // AVAudioPCMBuffer Float 배열 추출 함수
    func extractFloatArray(from buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData?[0] else {
            return []
        }
        let frameLength = Int(buffer.frameLength)
        return Array(UnsafeBufferPointer(start: channelData, count: frameLength))
    }
    
    // 오디오 세션 설정하기
    func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.record, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.step = .error("마이크 접근 권한이 필요합니다")
            }
        }
    }
    
    // 오디오 측정을 시작하는 함수
    func startAudioMonitoring() {
        setupAudioSession()
        
        // 이전에 사용하던 엔진이 있다면 정리
        stopAudioMonitoring()
        
        engine = AVAudioEngine()
        guard let engine = engine else { return }
        inputNode = engine.inputNode
        recordingBuffer.removeAll()

        let format = inputNode?.outputFormat(forBus: 0) ?? AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: outputSampleRate, channels: 1, interleaved: false)!
        self.converter = AVAudioConverter(from: format, to: outputFormat)
        
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] (buffer, time) in
            guard let self = self else { return }
            
            let magnitudes = self.fftFromBuffer(buffer)
            DispatchQueue.main.async {
                self.audioLevels = magnitudes
            }
            
            guard let converter = self.converter else { return }

            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(outputFormat.sampleRate) * buffer.frameLength / AVAudioFrameCount(format.sampleRate))!

            let status = converter.convert(to: convertedBuffer, error: nil, withInputFrom: inputBlock)
            if status == .haveData {
                if let floatData = convertedBuffer.floatChannelData?[0] {
                    let frameLength = Int(convertedBuffer.frameLength)
                    let newData = Array(UnsafeBufferPointer(start: floatData, count: frameLength))
                    self.recordingBuffer.append(contentsOf: newData)
                }
            }
        }

        do {
            try engine.start()
            print("AVAudioEngine 시작됨")
            startRecordingTimer()
            DispatchQueue.main.async {
                self.step = .recording
                self.recordingProgress = 0.0
            }
        } catch {
            print("AVAudioEngine start 실패: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.step = .error("오디오 녹음을 시작할 수 없습니다")
            }
        }
    }

    // FFT 분석 및 주파수별 magnitude 계산 함수
    private func fftFromBuffer(_ buffer: AVAudioPCMBuffer) -> [Float] {
        let frameCount = Int(buffer.frameLength)
        let log2n = vDSP_Length(log2(Float(frameCount)))
        guard frameCount > 0, let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return Array(repeating: 0.0, count: audioLevels.count)
        }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        guard let channelData = buffer.floatChannelData?[0] else {
            return Array(repeating: 0.0, count: audioLevels.count)
        }
        
        var window = [Float](repeating: 0, count: frameCount)
        vDSP_hann_window(&window, vDSP_Length(frameCount), Int32(vDSP_HANN_NORM))
        var windowedSignal = [Float](repeating: 0, count: frameCount)
        vDSP_vmul(channelData, 1, window, 1, &windowedSignal, 1, vDSP_Length(frameCount))

        var real = [Float](repeating: 0, count: frameCount/2)
        var imag = [Float](repeating: 0, count: frameCount/2)
        var magnitudes = [Float](repeating: 0.0, count: frameCount / 2)
        var normalizedMagnitudes = [Float](repeating: 0.0, count: audioLevels.count)

        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)

                windowedSignal.withUnsafeBufferPointer {
                    guard let baseAddress = $0.baseAddress else { return }
                    baseAddress.withMemoryRebound(to: DSPComplex.self, capacity: frameCount) {
                        vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
                    }
                }

                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))

                guard audioLevels.count > 0 else { return }
                let step = magnitudes.count / audioLevels.count
                for i in 0..<audioLevels.count {
                    let start = i * step
                    let end = start + step
                    if start < magnitudes.count {
                        let validEnd = min(end, magnitudes.count)
                        let slice = magnitudes[start..<validEnd]
                        let avg = slice.reduce(0, +) / Float(slice.count)
                        let scaled = pow(avg, 0.5) / 5000.0
                        normalizedMagnitudes[i] = min(1.0, scaled)
                    }
                }
            }
        }

        return normalizedMagnitudes
    }
    
    // 녹음 타이머 시작
    private func startRecordingTimer() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.recordingProgress += 0.1 / self.recordingDuration
            
            if self.recordingProgress >= 1.0 {
                timer.invalidate()
                self.finishRecording()
            }
        }
    }
    
    // 녹음 완료 및 분석 시작
    private func finishRecording() {
        stopAudioMonitoring()
        
        DispatchQueue.main.async {
            self.step = .processing
        }
        
        // 분석 처리를 시뮬레이션 (실제로는 ML 모델을 적용하는 코드가 여기에 들어갈 것)
        analyzeAudio()
    }
    
    // MFCC [[Float]] -> MLMultiArray 변환 함수
    private func createMLMultiArray(from mfcc: [[Float]]) throws -> MLMultiArray {
        let flatArray = mfcc.flatMap { $0 }
        let array = try MLMultiArray(shape: [NSNumber(value: flatArray.count)], dataType: .float32)
        for (i, value) in flatArray.enumerated() {
            array[i] = NSNumber(value: value)
        }
        return array
    }

    // 오디오 분석 (아기 울음소리 감정 분류)
    private func analyzeAudio() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            let mfcc = MFCCExtractor().extract(from: self.recordingBuffer)
            guard !mfcc.isEmpty else {
                DispatchQueue.main.async {
                    self.step = .error("유효한 오디오 데이터를 분석하지 못했습니다.")
                }
                return
            }

            do {
                let mlArray = try self.createMLMultiArray(from: mfcc)
                let input = DeepInfant_V2Input(audioSamples: mlArray)
                let output = try self.model.prediction(input: input)

                guard let probs = output.featureValue(for: "classLabelProbs")?.dictionaryValue as? [String: Double],
                      let best = probs.max(by: { $0.value < $1.value }) else {
                    DispatchQueue.main.async {
                        self.step = .error("분석 결과를 읽을 수 없습니다.")
                    }
                    return
                }

                let mapped: EmotionResult
                switch best.key {
                case "hungry": mapped = EmotionResult(type: .hungry, confidence: best.value)
                case "sleepy": mapped = EmotionResult(type: .tired, confidence: best.value)
                case "discomfort": mapped = EmotionResult(type: .discomfort, confidence: best.value)
                case "belly_pain": mapped = EmotionResult(type: .scared, confidence: best.value)
                case "burping": mapped = EmotionResult(type: .lonely, confidence: best.value)
                default: mapped = EmotionResult(type: .hungry, confidence: best.value)
                }

                DispatchQueue.main.async {
                    self.step = .result(mapped)
                }

            } catch {
                DispatchQueue.main.async {
                    self.step = .error("분석 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func stopAudioMonitoring() {
        analysisTimer?.invalidate()
        analysisTimer = nil
        
        inputNode?.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        inputNode = nil
    }

    func cancel() {
        stopAudioMonitoring()
        step = .start
        recordingProgress = 0.0
    }

    func startAnalysis() {
        startAudioMonitoring()
    }
}
