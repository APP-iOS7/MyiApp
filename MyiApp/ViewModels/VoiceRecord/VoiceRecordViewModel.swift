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

    private enum AudioEngineError: Error {
        case initializationFailed
    }

    private func configureEngine(tapHandler: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) throws {
        setupAudioSession()
        stopAudioMonitoring()
        
        engine = AVAudioEngine()
        guard let engine = engine else {
            throw AudioEngineError.initializationFailed
        }
        inputNode = engine.inputNode
        recordingBuffer.removeAll()

        let inputFormat = inputNode!.outputFormat(forBus: 0)
        inputNode!.installTap(onBus: 0, bufferSize: 1024, format: inputFormat, block: tapHandler)

        try engine.start()
    }
    
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
        do {
            try configureEngine { buffer, time in
                // 기존 FFT + converter + buffer append 로직 유지
                let magnitudes = self.fftFromBuffer(buffer)
                DispatchQueue.main.async {
                    self.audioLevels = magnitudes
                }

                guard let converter = self.converter else { return }
                
                let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                    outStatus.pointee = .haveData
                    return buffer
                }
                
                let inputFormat = self.inputNode!.outputFormat(forBus: 0)
                let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                                 sampleRate: 22050,
                                                 channels: 1,
                                                 interleaved: false)!
                
                let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat,
                                                       frameCapacity: AVAudioFrameCount(outputFormat.sampleRate) * buffer.frameLength / AVAudioFrameCount(inputFormat.sampleRate))!
                
                let status = converter.convert(to: convertedBuffer, error: nil, withInputFrom: inputBlock)
                if status == .haveData, let floatData = convertedBuffer.floatChannelData?[0] {
                    let newData = Array(UnsafeBufferPointer(start: floatData, count: Int(convertedBuffer.frameLength)))
                    self.recordingBuffer.append(contentsOf: newData)
                }
            }
            print("✅ AVAudioEngine 시작됨")
            startRecordingTimer()
            DispatchQueue.main.async {
                self.step = .recording
                self.recordingProgress = 0.0
            }
        } catch {
            print("❌ 오디오 엔진 구성 실패: \(error)")
            DispatchQueue.main.async {
                self.step = .error("오디오 녹음을 시작할 수 없습니다.")
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
        
        recordAndAnalyzeCry { result in
            DispatchQueue.main.async {
                self.step = .result(result)
            }
        }

        print("📈 최종 녹음된 샘플 수: \(recordingBuffer.count)")
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
    
    
    func recordAndAnalyzeCry(completion: @escaping (EmotionResult) -> Void) {
        do {
            try configureEngine { buffer, time in
                let floatArray = self.extractFloatArray(from: buffer)
                self.recordingBuffer.append(contentsOf: floatArray)
            }
            print("🎧 AVAudioEngine 시작됨")
        } catch {
            print("❌ 오디오 엔진 구성 실패: \(error)")
            step = .error("엔진 시작 실패")
            return
        }

        // 일정 시간 후 분석
        DispatchQueue.main.asyncAfter(deadline: .now() + recordingDuration) {
            self.inputNode?.removeTap(onBus: 0)
            self.engine?.stop()
            print("🎙️ 녹음 완료, 샘플 수: \(self.recordingBuffer.count)")

            let extractor = MFCCExtractor()
            let mfccFeatures = extractor.extract(from: self.recordingBuffer)
            print("✅ MFCC 개수: \(mfccFeatures.count)")
            // Debug prints before checking MFCC validity
            print("🎯 입력 길이: \(self.recordingBuffer.count)")
            print("📐 프레임 수: \(mfccFeatures.count)")
            if let firstMFCC = mfccFeatures.first {
                print("🎼 첫 번째 MFCC 벡터: \(firstMFCC)")
            }

            guard !mfccFeatures.isEmpty else {
                self.step = .error("MFCC 추출 실패")
                return
            }


            do {
                let targetCount = 15600
                let trimmed = Array(self.recordingBuffer.prefix(targetCount)) +
                              Array(repeating: 0.0, count: max(0, targetCount - self.recordingBuffer.count))

                let inputArray = try MLMultiArray(shape: [NSNumber(value: targetCount)], dataType: .float32)
                for (i, value) in trimmed.enumerated() {
                    inputArray[i] = NSNumber(value: value)
                }

                let input = DeepInfant_V2Input(audioSamples: inputArray)
                let output = try self.model.prediction(input: input)
                let label = output.target
                let confidence = output.targetProbability[label] ?? 0.0

                let result = EmotionResult(type: EmotionType(rawValue: label) ?? .unknown, confidence: confidence)
                print("🔍 분석 결과: \(label), 신뢰도: \(confidence)")

                completion(result)
            } catch {
                print("❌ CoreML 추론 실패: \(error.localizedDescription)")
                self.step = .error("모델 추론 실패")
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
        step = .processing
        print("🟡 분석 시작됨")
        
        recordAndAnalyzeCry { result in
            DispatchQueue.main.async {
                self.step = .result(result)
            }
        }
    }
}
