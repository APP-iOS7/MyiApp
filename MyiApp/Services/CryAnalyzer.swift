//
//  CryAnalyzer.swift
//  MyiApp
//
//  Created by 조영민 on 5/20/25.
//

import Foundation
import CoreML
import Accelerate

final class CryAnalyzer {
    
    // MARK: - Constants
    private let mfccTargetSampleCount = 15600
    private let model: DeepInfant_V2
    
    // MARK: - Init
    init() {
        do {
            self.model = try DeepInfant_V2(configuration: MLModelConfiguration())
        } catch {
            fatalError("CoreML 모델 로드 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Method
    
    func analyze(from samples: [Float], completion: @escaping (EmotionResult?) -> Void) {
        print("[CryAnalyzer] 분석 시작: 입력 샘플 수 = \(samples.count)")

        let processedSamples = prepareSamples(samples)
        guard let inputArray = createMLMultiArray(from: processedSamples) else {
            print("[CryAnalyzer] MLMultiArray 생성 실패")
            completion(nil)
            return
        }

        print("[CryAnalyzer] MLMultiArray 구성 완료")

        do {
            let input = DeepInfant_V2Input(audioSamples: inputArray)
            let output = try model.prediction(input: input)

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

    private func prepareSamples(_ samples: [Float]) -> [Float] {
        let trimmed = Array(samples.prefix(mfccTargetSampleCount))
        let padding = Array(repeating: Float(0.0), count: max(0, mfccTargetSampleCount - trimmed.count))
        let result = trimmed + padding
        print("[CryAnalyzer] 입력 샘플 보정 완료 (\(result.count)개)")
        return result
    }

    private func createMLMultiArray(from samples: [Float]) -> MLMultiArray? {
        guard let array = try? MLMultiArray(shape: [NSNumber(value: samples.count)], dataType: .float32) else {
            return nil
        }
        for (i, value) in samples.enumerated() {
            array[i] = NSNumber(value: value)
        }
        return array
    }
}
