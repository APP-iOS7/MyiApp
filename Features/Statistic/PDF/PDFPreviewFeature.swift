import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct PDFPreviewFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
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
        public enum ViewAction {
            case shareTapped
            case dismissTapped
        }

        public enum InternalAction {
            case pdfGenerated(URL)
        }

        case view(ViewAction)
        case _internal(InternalAction)

        case binding(BindingAction<State>)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.pdfExporter) var pdfExporter

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.shareTapped):
                guard state.canShare else { return .none }
                return .run { [state, pdfExporter] send in
                    if let url = await pdfExporter.renderPDF(state.baby, state.records, state.date, state.fileName) {
                        await send(._internal(.pdfGenerated(url)))
                    }
                }

            case let ._internal(.pdfGenerated(url)):
                state.sharingURL = ShareableURL(url: url)
                return .none

            case .view(.dismissTapped):
                return .run { [dismiss] _ in await dismiss() }

            case .binding:
                return .none
            }
        }
    }
}

public struct ShareableURL: Identifiable, Equatable, Sendable {
    public let url: URL
    public var id: URL { url }

    public init(url: URL) {
        self.url = url
    }
}
