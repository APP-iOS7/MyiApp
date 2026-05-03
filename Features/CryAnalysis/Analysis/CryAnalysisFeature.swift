import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CryAnalysisFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var stage: Stage = .recording
        public var volume: Float = 0
        public var progress: Double = 0

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action {
        public enum ViewAction {
            case task
            case cancelTapped
            case dismissTapped
        }

        public enum InternalAction {
            case tick(volume: Float, progress: Double)
            case recordingFailed
            case analysisFailed
            case tickingStarted(URL)
            case recordingFinished(URL)
            case analysisSucceeded(CryAnalysisRecord)
        }

        case view(ViewAction)
        case _internal(InternalAction)
    }

    @Dependency(\.audioRecorderClient) var audioRecorderClient
    @Dependency(\.cryAnalysisClient)   var cryAnalysisClient
    @Dependency(\.cryRecordClient)     var cryRecordClient
    @Dependency(\.continuousClock)     var clock
    @Dependency(\.uuid)                var uuid
    @Dependency(\.dismiss)             var dismiss

    private enum CancelID { case lifecycle }

    private let recordingDurationSeconds: Double = 7
    private let tickIntervalMilliseconds: Int = 50

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .task:
                    return .run { [audioRecorderClient, uuid] send in
                        let url = FileManager.default.temporaryDirectory
                            .appendingPathComponent(uuid().uuidString)
                            .appendingPathExtension("caf")
                        await withTaskCancellationHandler {
                            do {
                                try await audioRecorderClient.startRecording(url)
                            } catch {
                                await send(._internal(.recordingFailed))
                                try? FileManager.default.removeItem(at: url)
                                return
                            }
                            await send(._internal(.tickingStarted(url)))
                        } onCancel: {
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                    .cancellable(id: CancelID.lifecycle)

                case .cancelTapped:
                    return .merge(
                        .cancel(id: CancelID.lifecycle),
                        .run { [audioRecorderClient] _ in
                            await audioRecorderClient.cancelRecording()
                        },
                        .run { [dismiss] _ in await dismiss() }
                    )

                case .dismissTapped:
                    return .run { [dismiss] _ in await dismiss() }
                }

            case let ._internal(internalAction):
                switch internalAction {
                case let .tickingStarted(url):
                    return .run { [audioRecorderClient, clock, recordingDurationSeconds, tickIntervalMilliseconds] send in
                        await withTaskCancellationHandler {
                            let totalTicks = Int(recordingDurationSeconds * 1000) / tickIntervalMilliseconds
                            var index = 0
                            for await _ in clock.timer(interval: .milliseconds(tickIntervalMilliseconds)) {
                                index += 1
                                let volume = await audioRecorderClient.currentVolume() ?? 0
                                await send(._internal(.tick(volume: volume, progress: Double(index) / Double(totalTicks))))
                                if index >= totalTicks { break }
                            }
                            guard !Task.isCancelled else { return }
                            await audioRecorderClient.stopRecording()
                            await send(._internal(.recordingFinished(url)))
                        } onCancel: {
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                    .cancellable(id: CancelID.lifecycle)

                case let .recordingFinished(url):
                    return .run { [cryAnalysisClient] send in
                        await withTaskCancellationHandler {
                            do {
                                let record = try await cryAnalysisClient.analyze(url)
                                await send(._internal(.analysisSucceeded(record)))
                            } catch {
                                await send(._internal(.analysisFailed))
                            }
                            try? FileManager.default.removeItem(at: url)
                        } onCancel: {
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                    .cancellable(id: CancelID.lifecycle)

                case .recordingFailed:
                    state.stage = .failure(.recordingFailed)
                    return .none

                case .analysisFailed:
                    state.stage = .failure(.analysisFailed)
                    return .none

                case let .tick(volume, progress):
                    state.volume = volume
                    state.progress = progress
                    return .none

                case let .analysisSucceeded(record):
                    let scores = record.aggregatedScores
                    state.stage = .result(
                        ResultDisplay(
                            primary: scores.first ?? EmotionScore(emotion: .unknown, confidence: 0),
                            others: Array(scores.dropFirst().prefix(3))
                        )
                    )
                    return .run { [cryRecordClient, babyID = state.baby.id, record] _ in
                        try? await cryRecordClient.addRecord(babyID, record)
                    }
                }
            }
        }
    }
}

extension CryAnalysisFeature {
    public enum Stage: Equatable {
        case recording
        case result(ResultDisplay)
        case failure(Failure)
    }

    public struct ResultDisplay: Equatable {
        public let primary: EmotionScore
        public let others: [EmotionScore]
    }

    public enum Failure: Equatable {
        case recordingFailed
        case analysisFailed
    }
}
