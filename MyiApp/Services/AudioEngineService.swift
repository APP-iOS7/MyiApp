//
//  AudioEngineService.swift
//  MyiApp
//
//  Created by 조영민 on 5/20/25.
//

import Foundation
import AVFoundation
import Accelerate

final class AudioEngineService {
    
    // MARK: - Public Properties
    var audioLevelsHandler: (([Float]) -> Void)?
    var bufferHandler: (([Float]) -> Void)?
    
    // MARK: - Private Properties
    private let fftBarCount = 8
    private let fftNormalizationFactor: Float = 5000.0
    
    private let sampleRate: Double = 22050
    private var engine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var converter: AVAudioConverter?
    
    // MARK: - Public Methods
    
    func startRecording(onPermissionResult: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.handlePermissionResult(granted, onPermissionResult: onPermissionResult)
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.handlePermissionResult(granted, onPermissionResult: onPermissionResult)
                }
            }
        }
    }

    private func handlePermissionResult(_ granted: Bool, onPermissionResult: @escaping (Bool) -> Void) {
        if granted {
            do {
                try self.configureAudioSession()
                try self.configureEngine()
                try self.engine?.start()
                onPermissionResult(true)
            } catch {
                print("Failed to start recording: \(error)")
                onPermissionResult(false)
            }
        } else {
            print("Microphone permission denied.")
            onPermissionResult(false)
        }
    }

    func stopRecording() {
        inputNode?.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        inputNode = nil
    }
    
    // MARK: - Private Methods
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)
    }
    
    private func configureEngine() throws {
        engine = AVAudioEngine()
        guard let engine = engine else { throw NSError(domain: "AudioEngineInit", code: -1) }
        
        inputNode = engine.inputNode
        let inputFormat = inputNode!.outputFormat(forBus: 0)
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                         sampleRate: sampleRate,
                                         channels: 1,
                                         interleaved: false)!

        converter = AVAudioConverter(from: inputFormat, to: outputFormat)
        
        inputNode!.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
            let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
            let avg = samples.reduce(0, +) / Float(samples.count)
            print("[AudioService] 버퍼 수신: \(samples.count)개, 평균값: \(avg)")
            self?.processBuffer(buffer, inputFormat: inputFormat, outputFormat: outputFormat)
        }
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer,
                               inputFormat: AVAudioFormat,
                               outputFormat: AVAudioFormat) {
        
        // Equalizer (FFT)
        let levels = fftFromBuffer(buffer)
        DispatchQueue.main.async {
            self.audioLevelsHandler?(levels)
        }

        // Float32 PCM 변환
        guard let converter = converter else { return }

        let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat,
                                               frameCapacity: buffer.frameCapacity)!
        
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        let status = converter.convert(to: convertedBuffer, error: nil, withInputFrom: inputBlock)
        
        if status == .haveData, let floatData = convertedBuffer.floatChannelData?[0] {
            let samples = Array(UnsafeBufferPointer(start: floatData, count: Int(convertedBuffer.frameLength)))
            DispatchQueue.main.async {
                self.bufferHandler?(samples)
            }
        }
    }
    
    // MARK: - FFT Equalizer
    private func fftFromBuffer(_ buffer: AVAudioPCMBuffer) -> [Float] {
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return Array(repeating: 0.0, count: fftBarCount) }
        
        let log2n = vDSP_Length(log2(Float(frameCount)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return Array(repeating: 0.0, count: fftBarCount)
        }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        guard let channelData = buffer.floatChannelData?[0] else {
            return Array(repeating: 0.0, count: fftBarCount)
        }

        var window = [Float](repeating: 0.0, count: frameCount)
        var windowedSignal = [Float](repeating: 0.0, count: frameCount)
        vDSP_hann_window(&window, vDSP_Length(frameCount), Int32(vDSP_HANN_NORM))
        vDSP_vmul(channelData, 1, window, 1, &windowedSignal, 1, vDSP_Length(frameCount))

        var real = [Float](repeating: 0, count: frameCount / 2)
        var imag = [Float](repeating: 0, count: frameCount / 2)
        var magnitudes = [Float](repeating: 0, count: frameCount / 2)
        var normalizedMagnitudes = [Float](repeating: 0, count: fftBarCount)

        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                windowedSignal.withUnsafeBufferPointer {
                    $0.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: frameCount) {
                        vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(frameCount / 2))
                    }
                }
                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))
            }
        }

        let step = magnitudes.count / fftBarCount
        for i in 0..<fftBarCount {
            let slice = magnitudes[i * step ..< min((i + 1) * step, magnitudes.count)]
            let avg = slice.reduce(0, +) / Float(slice.count)
            normalizedMagnitudes[i] = min(1.0, pow(avg, 0.5) / fftNormalizationFactor)
        }

        return normalizedMagnitudes
    }
}
