//
//  VoiceRecordViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import Combine
import FirebaseFirestore

enum CryAnalysisStep: Equatable {
    case start
    case recording
    case processing
    case result(EmotionResult)
    case error(String)
    
    static func == (lhs: CryAnalysisStep, rhs: CryAnalysisStep) -> Bool {
        switch (lhs, rhs) {
        case (.start, .start):
            return true
        case (.recording, .recording):
            return true
        case (.processing, .processing):
            return true
        case let (.result(lhsResult), .result(rhsResult)):
            return lhsResult.type == rhsResult.type &&
                   lhsResult.confidence == rhsResult.confidence
        case let (.error(lhsMsg), .error(rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

final class VoiceRecordViewModel: ObservableObject {
    let careGiverManager = CaregiverManager.shared

    // MARK: - Published State
    @Published var audioLevels: [Float] = Array(repeating: 0.0, count: 8)
    @Published var recordingProgress: Double = 0.0
    @Published var step: CryAnalysisStep = .start
    @Published var recordResults: [VoiceRecord] = []
    @Published var analysisCompleted: Bool = false
    @Published var shouldDismissResultView: Bool = false

    // MARK: - Private
    private let audioService = AudioEngineService()
    private let analyzer = CryAnalyzer()
    private var cancellables = Set<AnyCancellable>()

    private var recordingBuffer: [Float] = []
    private var analysisTimer: Timer?
    private var hasStarted = false

    // MARK: - Init
    init() {
        observeStep()
    }

    // MARK: - Public Methods
    func startAnalysis() {
        guard !hasStarted else { return }
        hasStarted = true
        step = .recording
        recordingProgress = 0.0
        recordingBuffer.removeAll()
        shouldDismissResultView = false

        audioService.audioLevelsHandler = { [weak self] levels in
            self?.audioLevels = levels
        }

        audioService.bufferHandler = { [weak self] samples in
            self?.recordingBuffer.append(contentsOf: samples)
        }

        do {
            try audioService.startRecording()
            startRecordingTimer()
        } catch {
            step = .error("오디오 녹음을 시작할 수 없습니다.")
        }
    }

    func cancel() {
        stop()
        resetAnalysisState()
    }

    func resetAnalysisState() {
        step = .start
        analysisCompleted = false
        hasStarted = false
        recordingProgress = 0.0
        recordingBuffer.removeAll()
    }

    func resetAnalysisCompleted() {
        analysisCompleted = false
    }

    var analysisCompletedPublisher: some Publisher<Bool, Never> {
        $analysisCompleted.removeDuplicates()
    }

    func dismissResultView() {
        shouldDismissResultView = true
    }

    func saveAnalysisResult(newResult: VoiceRecord) async throws {
        guard let babyID = careGiverManager.selectedBaby?.id.uuidString else {
            return
        }

        let db = Firestore.firestore()
        _ = db.collection("babies")
            .document(babyID)
            .collection("voiceRecords")
            .document(newResult.id.uuidString)
            .setData(from: newResult)
    }

    // MARK: - Private Methods

    private func observeStep() {
        $step
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStep in
                self?.handleStepChange(newStep)
            }
            .store(in: &cancellables)
    }

    private func handleStepChange(_ newStep: CryAnalysisStep) {
        guard case let .result(emotion) = newStep, !analysisCompleted else { return }

        let newResult = VoiceRecord(
            id: UUID(),
            createdAt: Date(),
            recordReference: "",
            firstLabel: emotion.type,
            firstLabelConfidence: emotion.confidence,
            secondLabel: .unknown,
            secondLabelConfidence: 0.0
        )

        recordResults.insert(newResult, at: 0)
        analysisCompleted = true

        Task {
            do {
                try await saveAnalysisResult(newResult: newResult)
            } catch {
                print("🔥 Firebase 저장 실패: \(error)")
            }
        }
    }

    private func stop() {
        analysisTimer?.invalidate()
        analysisTimer = nil
        audioService.stopRecording()
    }

    private func startRecordingTimer() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            self.recordingProgress += 0.1 / 7.0

            if self.recordingProgress >= 1.0 {
                timer.invalidate()
                self.finishRecording()
            }
        }
    }

    private func finishRecording() {
        stop()
        step = .processing

        analyzer.analyze(from: recordingBuffer) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.step = result.map { .result($0) } ?? .error("분석 실패")
            }
        }
    }
}
