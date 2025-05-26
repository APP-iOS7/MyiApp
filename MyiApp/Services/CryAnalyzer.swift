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
        
        // Core ML 입력 포맷으로 변환
        guard let inputArray = createMLMultiArray(from: processedSamples) else {
            print("[CryAnalyzer] MLMultiArray 생성 실패")
            completion(nil)
            return
        }

        print("[CryAnalyzer] MLMultiArray 구성 완료")

        do {
            // 모델 입력 생성 및 추론 실행
            let input = DeepInfant_V2Input(audioSamples: inputArray)
            let output = try model.prediction(input: input)

            print("[CryAnalyzer] 전체 예측 확률:")
            for (label, prob) in output.targetProbability {
                print(" - \(label): \(prob)")
            }

            // 예측 결과 추출 및 래핑
            let label = output.target // 모델이 가장 가능성이 높다고 판단한 감정을 반환
            let confidence = output.targetProbability[label] ?? 0.0 // 각 감정에 대해 모델이 예측한 확률, 만약 딕셔너리에 해당 키가 없다면 기본값 0.0을 넣음
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
}
