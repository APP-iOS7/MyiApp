import Shared
import SwiftUI

public struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
        if let image = cachedImage(for: url) {
            _phase = State(initialValue: .success(image))
        }
    }

    private func cachedImage(for url: URL?) -> Image? {
        guard let url,
              let data = ImageCache.shared.cachedDataSync(for: url),
              let uiImage = UIImage(data: data)
        else { return nil }

        return Image(uiImage: uiImage)
    }

    public var body: some View {
        content(phase)
            .task(id: url) {
                await load()
            }
    }

    private func load() async {
        guard let url else {
            phase = .empty
            return
        }

        do {
            let data = try await ImageCache.shared.data(for: url)
            guard let uiImage = UIImage(data: data) else {
                phase = .failure(ImageDecodingError.invalidData)
                return
            }

            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }
}

private enum ImageDecodingError: Error {
    case invalidData
}
