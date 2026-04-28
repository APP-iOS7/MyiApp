import ComposableArchitecture
import CoreML
import Domain
import Foundation
import SoundAnalysis

extension CryAnalysisClient: @retroactive TestDependencyKey {}
extension CryAnalysisClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        analyze: { @Sendable url async throws(CryAnalysisError) -> CryAnalysisRecord in
            let windows = try await analyzeFile(url: url)
            return CryAnalysisRecord(windows: windows)
        }
    )
}

public extension DependencyValues {
    var cryAnalysisClient: CryAnalysisClient {
        get { self[CryAnalysisClient.self] }
        set { self[CryAnalysisClient.self] = newValue }
    }
}

// MARK: - Analysis

private func analyzeFile(url: URL) async throws(CryAnalysisError) -> [[EmotionScore]] {
    guard let modelURL = Bundle.main.url(forResource: "DeepInfant_V2", withExtension: "mlmodelc") else {
        throw .modelInferenceFailed
    }

    let model: MLModel
    do { model = try MLModel(contentsOf: modelURL) }
    catch { throw .modelInferenceFailed }

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
    case let .failure(error):   throw error
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
