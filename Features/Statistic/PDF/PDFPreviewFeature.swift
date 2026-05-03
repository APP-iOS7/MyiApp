import ComposableArchitecture
import Domain
import Foundation
import SwiftUI

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
        public enum InternalAction {
            case pdfGenerated(URL)
        }

        case binding(BindingAction<State>)
        case shareTapped
        case dismissTapped
        case _internal(InternalAction)
    }

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .shareTapped:
                guard state.canShare else { return .none }
                return .run { [state] send in
                    if let url = await MainActor.run(body: { generatePDF(state: state) }) {
                        await send(._internal(.pdfGenerated(url)))
                    }
                }

            case let ._internal(.pdfGenerated(url)):
                state.sharingURL = ShareableURL(url: url)
                return .none

            case .dismissTapped:
                return .run { _ in await dismiss() }

            case .binding:
                return .none
            }
        }
    }

    @MainActor
    private func generatePDF(state: State) -> URL? {
        let trimmed = state.fileName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let renderer = ImageRenderer(content: StatisticPDFContent(
            baby: state.baby,
            records: state.records,
            date: state.date
        ))
        renderer.scale = UIScreen.main.scale

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(trimmed).pdf")
        var success = false
        renderer.render { size, draw in
            var mediaBox = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &mediaBox, nil) else { return }
            pdf.beginPDFPage(nil)
            draw(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            success = true
        }
        return success ? url : nil
    }
}

public struct ShareableURL: Identifiable, Equatable {
    public let url: URL
    public var id: URL { url }

    public init(url: URL) {
        self.url = url
    }
}
