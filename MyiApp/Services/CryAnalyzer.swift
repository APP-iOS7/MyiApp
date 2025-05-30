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
            print("[CryAnalyzer] 무음 감지됨")
            let result = EmotionResult(type: .unknown, confidence: 0.0)
            completion(result)
            return
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

    private func isSilent(samples: [Float], threshold: Float = 0.001) -> Bool {
        var rms: Float = 0.0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))
        return rms < threshold
    }

private func isSilent(buffer: AVAudioPCMBuffer, threshold: Float = 0.001) -> Bool {
    guard let floatChannelData = buffer.floatChannelData else { return true }
    let frameLength = Int(buffer.frameLength)

    var rms: Float = 0.0
    vDSP_rmsqv(floatChannelData[0], 1, &rms, vDSP_Length(frameLength))
    return rms < threshold
}
}
