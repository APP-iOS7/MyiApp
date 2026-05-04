import ComposableArchitecture
import SwiftUI

extension PDFExporter: DependencyKey {
    public static let liveValue = Self(
        renderPDF: { baby, records, date, fileName in
            let trimmed = fileName.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }

            return await MainActor.run {
                let renderer = ImageRenderer(content: StatisticPDFContent(baby: baby, records: records, date: date))
                renderer.proposedSize = ProposedViewSize(width: UIScreen.main.bounds.width, height: nil)
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
    )
}
