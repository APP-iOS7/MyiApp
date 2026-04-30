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

        /// 수유 sub-카테고리 전환 + 값
        public var feedingKind: FeedingKind
        public var feedingMl: Int
        public var breastLeftMinutes: Int
        public var breastRightMinutes: Int

        /// 체온 (°C)
        public var temperatureCelsius: Double

        /// 키/몸무게 (각자 미기록 가능)
        public var heightCm: Double?
        public var weightKg: Double?

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

            switch record.event {
            case let .formula(ml):
                feedingKind = .formula
                feedingMl = ml
                breastLeftMinutes = 10
                breastRightMinutes = 10
            case let .babyFood(ml):
                feedingKind = .babyFood
                feedingMl = ml
                breastLeftMinutes = 10
                breastRightMinutes = 10
            case let .pumpedMilk(ml):
                feedingKind = .pumpedMilk
                feedingMl = ml
                breastLeftMinutes = 10
                breastRightMinutes = 10
            case let .breastfeeding(left, right):
                feedingKind = .breastfeeding
                feedingMl = 100
                breastLeftMinutes = left
                breastRightMinutes = right
            default:
                feedingKind = .formula
                feedingMl = 100
                breastLeftMinutes = 10
                breastRightMinutes = 10
            }

            switch record.event {
            case let .temperature(c): temperatureCelsius = c
            default:                  temperatureCelsius = 36.5
            }

            switch record.event {
            case let .heightWeight(h, w):
                heightCm = h
                weightKg = w
            default:
                heightCm = nil
                weightKg = nil
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

            case .formula, .babyFood, .pumpedMilk, .breastfeeding:
                switch feedingKind {
                case .formula:       .formula(ml: feedingMl)
                case .babyFood:      .babyFood(ml: feedingMl)
                case .pumpedMilk:    .pumpedMilk(ml: feedingMl)
                case .breastfeeding: .breastfeeding(leftMinutes: breastLeftMinutes, rightMinutes: breastRightMinutes)
                }

            case .temperature:
                .temperature(celsius: temperatureCelsius)

            case .heightWeight:
                .heightWeight(heightCm: heightCm, weightKg: weightKg)

            default:
                originalEvent
            }
        }
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

extension EditRecordFeature {
    public enum PottyKind: Hashable, Sendable, CaseIterable {
        case pee
        case poop
        case both
    }

    public enum MedicalKind: Hashable, Sendable, CaseIterable {
        case medicine
        case clinic
    }

    public enum FeedingKind: Hashable, Sendable, CaseIterable {
        case formula
        case babyFood
        case pumpedMilk
        case breastfeeding
    }
}
