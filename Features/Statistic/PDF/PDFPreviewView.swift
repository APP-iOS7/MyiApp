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
                    StatisticPDFContent(
                        baby: store.baby,
                        records: store.records,
                        date: store.date
                    )
                }
                .scrollIndicators(.hidden)

                VStack(spacing: Spacing.m) {
                    UnderlinedTextField(placeholder: "파일 이름", text: $store.fileName)
                        .focused($isFileNameFocused)

                    Button("PDF로 저장 및 공유") { store.send(.shareTapped) }
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
        renderer.proposedSize = ProposedViewSize(width: UIScreen.main.bounds.width, height: nil)
        renderer.scale = UIScreen.main.scale
        image = renderer.uiImage
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
