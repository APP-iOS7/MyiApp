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
    @Published var step: CryAnalysisStep = .start {
        didSet {
            print("[ViewModel] step 변경됨 → \(step)")
        }
    }
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
    private var isProcessingResult = false

    // MARK: - Init
    init() {
        observeStep()
        // CaregiverManager에서 초기 데이터 로드
        recordResults = careGiverManager.voiceRecords
        
        // voiceRecords 배열의 변경사항 구독
        careGiverManager.$voiceRecords
            .sink { [weak self] records in
                self?.recordResults = records
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func startAnalysis() {
        print("[ViewModel] startAnalysis() called — step: \(step)")
        hasStarted = true
        step = .start
        recordingProgress = 0.0
        recordingBuffer.removeAll()
        shouldDismissResultView = false
        analysisCompleted = false
        isProcessingResult = false

        audioService.audioLevelsHandler = { [weak self] levels in
            self?.audioLevels = levels
        }

        audioService.bufferHandler = { [weak self] samples in
            self?.recordingBuffer.append(contentsOf: samples)
            let avg = samples.reduce(0, +) / Float(samples.count)
            print("[ViewModel] 새 샘플 수신: \(samples.count)개, 평균값: \(avg)")
        }

        audioService.startRecording { [weak self] granted in
            guard let self = self else { return }

            if granted {
                self.step = .recording
                self.startRecordingTimer()
            } else {
                self.step = .error("마이크 권한이 필요합니다.")
                self.shouldDismissResultView = true
            }
        }
    }

    func cancel() {
        stop()
        resetAnalysisState()
    }

    func resetAnalysisState() {
        // 결과 처리 중이면 바로 초기화하지 않음
        if isProcessingResult {
            return
        }

        step = .start
        shouldDismissResultView = false
        analysisCompleted = false
        hasStarted = false
        recordingProgress = 0.0
        recordingBuffer.removeAll()
        print("[ViewModel] resetAnalysisState() 완료 — step: \(step)")
    }

    func resetAnalysisCompleted() {
        analysisCompleted = false
    }

    var analysisCompletedPublisher: some Publisher<Bool, Never> {
        $analysisCompleted.removeDuplicates()
    }

    func dismissResultView() {
        shouldDismissResultView = true
        
        // 결과 화면이 닫히면 상태 초기화
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.resetAnalysisState()
        }
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
            .removeDuplicates()
            .sink { [weak self] newStep in
                self?.handleStepChange(newStep)
            }
            .store(in: &cancellables)
    }

    private func handleStepChange(_ newStep: CryAnalysisStep) {
        guard case let .result(emotion) = newStep, !analysisCompleted, !isProcessingResult else {
            return
        }

        isProcessingResult = true
        
        let newResult = VoiceRecord(
            id: UUID(),
            createdAt: Date(),
            recordReference: "",
            firstLabel: emotion.type,
            firstLabelConfidence: emotion.confidence,
            secondLabel: .unknown,
            secondLabelConfidence: 0.0
        )

        careGiverManager.voiceRecords.insert(newResult, at: 0)
        analysisCompleted = true

        Task {
            do {
                try await saveAnalysisResult(newResult: newResult)
            } catch {
                print("Firebase 저장 실패: \(error)")
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
        print("[ViewModel] finishRecording() 호출됨, 버퍼 길이: \(recordingBuffer.count)")

        analyzer.analyze(from: recordingBuffer) { [weak self] result in
            print("[ViewModel] 분석 결과 수신: \(String(describing: result))")
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.step = result.map { .result($0) } ?? .error("분석 실패")
            }
        }
    }
}
