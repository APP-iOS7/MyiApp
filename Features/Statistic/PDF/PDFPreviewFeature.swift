import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct PDFPreviewFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var records: [CareRecord]
        public var date: Date
        public var fileName: String
        public var sharingURL: ShareableURL?

        public init(baby: Baby, records: [CareRecord], date: Date) {
            self.baby = baby
            self.records = records
            self.date = date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            fileName = "\(formatter.string(from: date))_기록 분석"
        }

        public var canShare: Bool {
            !fileName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case shareRequested(URL)
        case dismissTapped
    }

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .shareRequested(url):
                state.sharingURL = ShareableURL(url: url)
                return .none

            case .dismissTapped:
                return .run { [dismiss] _ in await dismiss() }

            case .binding:
                return .none
            }
        }
    }
}

public struct ShareableURL: Identifiable, Equatable {
    public let url: URL
    public var id: URL { url }

    public init(url: URL) {
        self.url = url
    }
}
