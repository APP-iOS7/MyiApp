import ComposableArchitecture
import Domain
import Foundation

enum GrowthMode: String, CaseIterable, Equatable {
    case height = "키"
    case weight = "몸무게"

    var unit: String {
        switch self {
        case .height: "cm"
        case .weight: "kg"
        }
    }

    var fractionLength: Int {
        switch self {
        case .height: 1
        case .weight: 2
        }
    }

    func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(fractionLength)))
    }

    func formatWithUnit(_ value: Double) -> String {
        "\(format(value)) \(unit)"
    }
}

@Reducer
public struct GrowthChartFeature {
    @ObservableState
    public struct State: Equatable {
        var records: [CareRecord]
        var baby: Baby
        var mode: GrowthMode = .height
        var startDate: Date
        var endDate: Date = .init()
        var selectedEntry: GrowthEntry?

        public init(records: [CareRecord], baby: Baby) {
            self.records = records
            self.baby = baby
            startDate = baby.birthDate
        }

        var data: [(date: Date, value: Double)] {
            switch mode {
            case .height:
                records.compactMap { record -> (Date, Double)? in
                    guard case let .heightWeight(heightCm, _) = record.event,
                          let height = heightCm
                    else { return nil }

                    return (record.createdAt, height)
                }
                .sorted { $0.0 < $1.0 }

            case .weight:
                records.compactMap { record -> (Date, Double)? in
                    guard case let .heightWeight(_, weightKg) = record.event,
                          let weight = weightKg
                    else { return nil }

                    return (record.createdAt, weight)
                }
                .sorted { $0.0 < $1.0 }
            }
        }

        var latestEntry: (date: Date, value: Double)? {
            data.filter { $0.date <= Date() }.max(by: { $0.date < $1.date })
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)  // 자체 view 액션이 없어 binding 만 처리 — 컨벤션 예외
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.mode):
                state.selectedEntry = nil
                return .none

            case .binding:
                return .none
            }
        }
    }
}
