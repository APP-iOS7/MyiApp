import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct EditRecordFeature {
    @ObservableState
    public struct State: Equatable {
        public let babyID: UUID
        public let recordID: UUID
        public let originalEvent: CareEvent
        public var createdAt: Date

        // 수면 입력
        public var sleepStart: Date
        public var sleepEnd: Date?

        /// 배변 sub-카테고리 전환
        public var pottyKind: PottyKind

        /// 의료 sub-카테고리 전환
        public var medicalKind: MedicalKind

        public var content: String
        public var isSubmitting: Bool = false

        public init(record: CareRecord, babyID: UUID) {
            self.babyID = babyID
            recordID = record.id
            originalEvent = record.event
            createdAt = record.createdAt
            content = record.content ?? ""

            switch record.event {
            case let .sleep(start, end):
                sleepStart = start
                sleepEnd = end

            default:
                sleepStart = Date()
                sleepEnd = nil
            }

            switch record.event {
            case .pee:      pottyKind = .pee
            case .poop:     pottyKind = .poop
            case .pottyAll: pottyKind = .both
            default:        pottyKind = .pee
            }

            switch record.event {
            case .medicine: medicalKind = .medicine
            case .clinic:   medicalKind = .clinic
            default:        medicalKind = .clinic
            }
        }

        /// 편집된 CareEvent. 지원 안 하는 카테고리는 originalEvent 그대로.
        var event: CareEvent {
            switch originalEvent {
            case .sleep:
                .sleep(start: sleepStart, end: sleepEnd)

            case .pee, .poop, .pottyAll:
                switch pottyKind {
                case .pee:  .pee
                case .poop: .poop
                case .both: .pottyAll
                }

            case .medicine, .clinic:
                switch medicalKind {
                case .medicine: .medicine
                case .clinic:   .clinic
                }

            default:
                originalEvent
            }
        }
    }

    public enum PottyKind: Hashable, Sendable, CaseIterable {
        case pee
        case poop
        case both
    }

    public enum MedicalKind: Hashable, Sendable, CaseIterable {
        case medicine
        case clinic
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveTapped
        case deleteTapped
        case cancelTapped
        case markSleepEndNow
        case saveSucceeded
        case saveFailed(CareRecordError)
        case deleteSucceeded
        case deleteFailed(CareRecordError)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saved
            case deleted
        }
    }

    @Dependency(\.careRecordClient) var careRecordClient
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .saveTapped:
                guard !state.isSubmitting else { return .none }

                state.isSubmitting = true
                let record = CareRecord(
                    id: state.recordID,
                    createdAt: state.createdAt,
                    event: state.event,
                    content: state.content.isEmpty ? nil : state.content
                )
                let babyID = state.babyID
                return .run { [careRecordClient] send in
                    do throws(CareRecordError) {
                        try await careRecordClient.updateRecord(babyID, record)
                        await send(.saveSucceeded)
                    } catch {
                        await send(.saveFailed(error))
                    }
                }

            case .deleteTapped:
                guard !state.isSubmitting else { return .none }

                state.isSubmitting = true
                let babyID = state.babyID
                let recordID = state.recordID
                return .run { [careRecordClient] send in
                    do throws(CareRecordError) {
                        try await careRecordClient.deleteRecord(babyID, recordID)
                        await send(.deleteSucceeded)
                    } catch {
                        await send(.deleteFailed(error))
                    }
                }

            case .markSleepEndNow:
                state.sleepEnd = Date()
                return .none

            case .cancelTapped:
                return .run { [dismiss] _ in await dismiss() }

            case .saveSucceeded:
                state.isSubmitting = false
                return .run { [dismiss] send in
                    await send(.delegate(.saved))
                    await dismiss()
                }

            case .deleteSucceeded:
                state.isSubmitting = false
                return .run { [dismiss] send in
                    await send(.delegate(.deleted))
                    await dismiss()
                }

            case .saveFailed, .deleteFailed:
                state.isSubmitting = false
                return .none // TODO: 에러 알림

            case .delegate:
                return .none
            }
        }
    }
}
