import ComposableArchitecture
import CoreML
import Domain
import Foundation
import SoundAnalysis

extension MLModel: @retroactive @unchecked Sendable {}

extension CryAnalysisClient: @retroactive TestDependencyKey {}
extension CryAnalysisClient: @retroactive DependencyKey {
    public static let liveValue: Self = {
        let model: MLModel
        do {
            let coreMLModel = try DeepInfant_V2(configuration: MLModelConfiguration())
            _ = try SNClassifySoundRequest(mlModel: coreMLModel.model)
            model = coreMLModel.model
        } catch {
            fatalError("DeepInfant_V2 / SNClassifySoundRequest init failed: \(error.localizedDescription)")
        }

        return Self(
            analyze: { @Sendable url async throws(CryAnalysisError) -> CryAnalysisRecord in
                let windows = try await analyzeFile(url: url, model: model)
                return CryAnalysisRecord(windows: windows)
            }
        )
    }()
}

public extension DependencyValues {
    var cryAnalysisClient: CryAnalysisClient {
        get { self[CryAnalysisClient.self] }
        set { self[CryAnalysisClient.self] = newValue }
    }
}

// MARK: - Analysis

private func analyzeFile(url: URL, model: MLModel) async throws(CryAnalysisError) -> [[EmotionScore]] {
    let fileAnalyzer: SNAudioFileAnalyzer
    do { fileAnalyzer = try SNAudioFileAnalyzer(url: url) }
    catch { throw .audioFileUnreadable }

    let request: SNClassifySoundRequest
    do { request = try SNClassifySoundRequest(mlModel: model) }
    catch { throw .modelInferenceFailed }

    let observer = ResultsObserver()
    do { try fileAnalyzer.add(request, withObserver: observer) }
    catch { throw .modelInferenceFailed }

    let outcome: Result<[[EmotionScore]], CryAnalysisError> = await withCheckedContinuation { continuation in
        fileAnalyzer.analyze { didComplete in
            if didComplete {
                continuation.resume(returning: .success(observer.windows))
            } else {
                continuation.resume(returning: .failure(.modelInferenceFailed))
            }
        }
    }

    switch outcome {
    case let .success(windows): return windows
    case let .failure(error): throw error
    }
}

private final class ResultsObserver: NSObject, SNResultsObserving, @unchecked Sendable {
    var windows: [[EmotionScore]] = []

    func request(_: SNRequest, didProduce result: SNResult) {
        guard let classifyResult = result as? SNClassificationResult else { return }
        let scores = classifyResult.classifications.map { classification in
            let emotion = EmotionType(rawValue: classification.identifier) ?? .unknown
            return EmotionScore(emotion: emotion, confidence: classification.confidence)
        }
        windows.append(scores)
    }
}
