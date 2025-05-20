//
//  CryAnalyzer.swift
//  MyiApp
//
//  Created by 조영민 on 5/20/25.
//

import Foundation
import CoreML

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
        print("[CryAnlayzer] 분석 시작: 입력 샘플 수 = \(samples.count)")
        // 1. 입력 길이 보정 (패딩 or 잘라내기)
        let trimmed = Array(samples.prefix(mfccTargetSampleCount)) +
                      Array(repeating: 0.0, count: max(0, mfccTargetSampleCount - samples.count))
        print("[CryAnalyzer] 입력 샘플 보정 완료 (\(trimmed.count)개)")
        
        // 2. MLMultiArray 변환
        guard let inputArray = try? MLMultiArray(shape: [NSNumber(value: mfccTargetSampleCount)],
                                                 dataType: .float32) else {
            print("MLMultiArray 생성 실패")
            completion(nil)
            return
        }
        
        for (i, value) in trimmed.enumerated() {
            inputArray[i] = NSNumber(value: value)
        }
        print("[CryAnalyzer] MLMultiArray 구성 완료")
        
        // 3. CoreML 추론
        do {
            let input = DeepInfant_V2Input(audioSamples: inputArray)
            let output = try model.prediction(input: input)
            
            let label = output.target
            let confidence = output.targetProbability[label] ?? 0.0
            let result = EmotionResult(
                type: EmotionType(rawValue: label) ?? .unknown,
                confidence: confidence
            )
            print("🎯 분석 결과: \(label) (\(confidence))")
            completion(result)
            
        } catch {
            print("❌ 모델 추론 실패: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
