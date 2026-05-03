import ComposableArchitecture
import Domain
import Foundation

public struct PDFExporter: Sendable {
    public var renderPDF: @Sendable (Baby, [CareRecord], Date, String) async -> URL?

    public init(renderPDF: @escaping @Sendable (Baby, [CareRecord], Date, String) async -> URL?) {
        self.renderPDF = renderPDF
    }
}

extension PDFExporter: TestDependencyKey {
    public static let testValue = Self(renderPDF: { _, _, _, _ in nil })
}

public extension DependencyValues {
    var pdfExporter: PDFExporter {
        get { self[PDFExporter.self] }
        set { self[PDFExporter.self] = newValue }
    }
}
