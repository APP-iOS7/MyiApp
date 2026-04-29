import SwiftUI

public struct LoadingOverlay: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color.black.opacity(Opacity.scrim).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.5)
        }
    }
}

public extension View {
    func loadingOverlay(isPresented: Bool) -> some View {
        overlay {
            if isPresented {
                LoadingOverlay()
            }
        }
        .disabled(isPresented)
    }
}

#Preview {
    Color.gray
        .loadingOverlay(isPresented: true)
}
