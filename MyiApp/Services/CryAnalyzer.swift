//
//  CryAnalyzer.swift
//  MyiApp
//
//  Created by 조영민 on 5/20/25.
//

import Foundation
import CoreML
import Accelerate
import AVFAudio

final class CryAnalyzer {
    
    // MARK: - Constants
    private let mfccTargetSampleCount = 15600 // Core ML 모델에 넣을 입력 데이터 샘플 수
    private let model: DeepInfant_V2
    
    private var silenceStartTime: Date?

    // MARK: - Init
    // 앱이 시작되면 Core ML 모델을 로딩
    init() {
        do {
            self.model = try DeepInfant_V2(configuration: MLModelConfiguration())
        } catch {
            fatalError("CoreML 모델 로드 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Method
    
    // 녹음된 오디오 샘플을 받아 감정 분석 수행
    // - Parameters:
    //   - samples: 음성 데이터 (Float 배열)
    //   - completion: 분석 결과를 반환하는 비동기 클로저
    func analyze(from samples: [Float], completion: @escaping (EmotionResult?) -> Void) {
        print("[CryAnalyzer] 분석 시작")
        print("[CryAnalyzer] 분석 시작: 입력 샘플 수 = \(samples.count)")

        let processedSamples = prepareSamples(samples) // 샘플 보정

        // 무음 판별 로직 추가
        if isSilent(samples: processedSamples) {
            if silenceStartTime == nil {
                silenceStartTime = Date()
            }

            let silenceDuration = Date().timeIntervalSince(silenceStartTime!)
            print("[CryAnalyzer] 무음 감지됨 (지속시간: \(silenceDuration))")
            let result = EmotionResult(type: .unknown, confidence: 0.0)
            completion(result)
            return
        } else {
            silenceStartTime = nil
        }

        guard let inputArray = createMLMultiArray(from: processedSamples) else {
            print("[CryAnalyzer] MLMultiArray 생성 실패")
            completion(nil)
            return
        }

        print("[CryAnalyzer] MLMultiArray 구성 완료")

        do {
            let input = DeepInfant_V2Input(audioSamples: inputArray)
            let output = try model.prediction(input: input)

            print("[CryAnalyzer] 전체 예측 확률:")
            for (label, prob) in output.targetProbability {
                print(" - \(label): \(prob)")
            }

            let label = output.target
            let confidence = output.targetProbability[label] ?? 0.0

            // confidence가 낮으면 unknown 처리
            if confidence < 0.5 {
                print("[CryAnalyzer] 예측 신뢰도 낮음 (\(confidence)), unknown 반환")
                let result = EmotionResult(type: .unknown, confidence: confidence)
                completion(result)
                return
            }

            let result = EmotionResult(
                type: EmotionType(rawValue: label) ?? .unknown,
                confidence: confidence
            )
            print("[CryAnalyzer] 분석 결과: \(label) (\(confidence))")
            completion(result)

        } catch {
            print("모델 추론 실패: \(error.localizedDescription)")
            completion(nil)
        }
    }

    // 입력 샘플 수를 모델 입력에 맞게 자르거나 0으로 패딩하는 함수
    private func prepareSamples(_ samples: [Float]) -> [Float] {
        let trimmed = Array(samples.prefix(mfccTargetSampleCount))
        let padding = Array(repeating: Float(0.0), count: max(0, mfccTargetSampleCount - trimmed.count))
        let result = trimmed + padding
        print("[CryAnalyzer] 입력 샘플 보정 완료 (\(result.count)개)")
        return result
    }

    // Float 배열을 Core ML에서 사용하는 MLMultiArray로 변환
    private func createMLMultiArray(from samples: [Float]) -> MLMultiArray? {
        guard let array = try? MLMultiArray(shape: [NSNumber(value: samples.count)], dataType: .float32) else {
            return nil
        }
        
        // 배열에 값 할당
        for (i, value) in samples.enumerated() {
            array[i] = NSNumber(value: value)
        }
        return array
    }

    private func isSilent(samples: [Float], rmsThreshold: Float = 0.0005, zeroRatioThreshold: Float = 0.98) -> Bool {
        var rms: Float = 0.0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))

        let silenceThreshold: Float = 0.001
        var zeroLikeCount: Int = 0
        for sample in samples {
            if abs(sample) < silenceThreshold {
                zeroLikeCount += 1
            }
        }
        let zeroRatio = Float(zeroLikeCount) / Float(samples.count)

        print("[isSilent] RMS: \(rms), ZeroRatio: \(zeroRatio)")

        let energyBasedSilent = rms < rmsThreshold && zeroRatio > zeroRatioThreshold && isDominantFrequencyLow(samples: samples, thresholdHz: 200.0)
        let patternBasedSilent = isNonCryLikeSignal(samples: samples) && rms < 0.001

        return energyBasedSilent || patternBasedSilent
    }

private func isSilent(buffer: AVAudioPCMBuffer, rmsThreshold: Float = 0.001, zeroRatioThreshold: Float = 0.95) -> Bool {
    guard let floatChannelData = buffer.floatChannelData else { return true }
    let frameLength = Int(buffer.frameLength)
    let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

    var rms: Float = 0.0
    vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))

    // 0에 가까운 값 비율 계산
    let silenceThreshold: Float = 0.001
    let zeroLikeCount = samples.filter { abs($0) < silenceThreshold }.count
    let zeroRatio = Float(zeroLikeCount) / Float(samples.count)

    return rms < rmsThreshold && zeroRatio > zeroRatioThreshold
}

private func isNonCryLikeSignal(samples: [Float], stddevThreshold: Float = 0.005) -> Bool {
    var mean: Float = 0
    var stddev: Float = 0
    vDSP_normalize(samples, 1, nil, 1, &mean, &stddev, vDSP_Length(samples.count))
    print("[isSilent] Signal StdDev: \(stddev)")
    return stddev < stddevThreshold
}
}

private func isDominantFrequencyLow(samples: [Float], thresholdHz: Float = 300.0, sampleRate: Float = 44100.0) -> Bool {
    var windowedSamples = samples
    var window = [Float](repeating: 0, count: samples.count)
    vDSP_hann_window(&window, vDSP_Length(samples.count), Int32(vDSP_HANN_NORM))
    vDSP_vmul(samples, 1, window, 1, &windowedSamples, 1, vDSP_Length(samples.count))

    var real = windowedSamples
    var imag = [Float](repeating: 0.0, count: samples.count)
    var result = true
    real.withUnsafeMutableBufferPointer { realPointer in
        imag.withUnsafeMutableBufferPointer { imagPointer in
            var splitComplex = DSPSplitComplex(realp: realPointer.baseAddress!, imagp: imagPointer.baseAddress!)
            let log2n = vDSP_Length(log2(Float(samples.count)))
            guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return }

            vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
            vDSP_destroy_fftsetup(fftSetup)

            let magnitudes = zip(realPointer, imagPointer).map { sqrt($0 * $0 + $1 * $1) }
            if let maxIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0.0) {
                let freq = Float(maxIndex) * sampleRate / Float(samples.count)
                print("[isSilent] Dominant Frequency: \(freq) Hz")
                result = freq < thresholdHz
            }
        }
    }
    return result
}
