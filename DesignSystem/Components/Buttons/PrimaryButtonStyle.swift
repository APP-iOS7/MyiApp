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
                .clipShape(RoundedRectangle(cornerRadius: Radius.m))
                .opacity(configuration.isPressed ? Opacity.pressed : 1)
        }
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: PrimaryButtonStyle { .init() }
}
