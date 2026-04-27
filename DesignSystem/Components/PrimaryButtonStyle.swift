import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Background(configuration: configuration)
    }

    private struct Background: View {
        let configuration: Configuration
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: ButtonSize.height)
                .background(isEnabled ? Color.Semantic.primaryAction : .gray)
                .clipShape(RoundedRectangle(cornerRadius: Radius.l))
                .opacity(configuration.isPressed ? 0.7 : 1)
        }
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}

#Preview {
    VStack(spacing: Spacing.m) {
        Button("다음") {}
            .buttonStyle(.primary)

        Button("다음") {}
            .buttonStyle(.primary)
            .disabled(true)
    }
    .padding()
}
