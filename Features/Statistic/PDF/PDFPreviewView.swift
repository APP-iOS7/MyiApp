import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct PDFPreviewView: View {
    @Bindable var store: StoreOf<PDFPreviewFeature>

    @State private var image: UIImage?
    @FocusState private var isFileNameFocused: Bool

    public init(store: StoreOf<PDFPreviewFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(Spacing.m)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 400)
                    }
                }

                VStack(spacing: Spacing.m) {
                    UnderlinedTextField(placeholder: "파일 이름", text: $store.fileName)
                        .focused($isFileNameFocused)

                    Button("PDF로 저장 및 공유", action: shareTapped)
                        .buttonStyle(.primary)
                        .disabled(image == nil || !store.canShare)
                }
                .padding(Spacing.m)
                .background(Color.Semantic.screenBackground)
            }
            .background(Color.Semantic.screenBackground.ignoresSafeArea())
            .navigationTitle("PDF 미리보기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { store.send(.dismissTapped) }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") { isFileNameFocused = false }
                }
            }
            .task { renderImage() }
            .sheet(item: $store.sharingURL) { wrapped in
                ActivityView(url: wrapped.url)
            }
        }
    }

    private func renderImage() {
        let renderer = ImageRenderer(content: StatisticPDFContent(
            baby: store.baby,
            records: store.records,
            date: store.date
        ))
        renderer.scale = UIScreen.main.scale
        image = renderer.uiImage
    }

    private func shareTapped() {
        if let url = generatePDF() {
            store.send(.shareRequested(url))
        }
    }

    private func generatePDF() -> URL? {
        let trimmed = store.fileName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let renderer = ImageRenderer(content: StatisticPDFContent(
            baby: store.baby,
            records: store.records,
            date: store.date
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

private struct ActivityView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
