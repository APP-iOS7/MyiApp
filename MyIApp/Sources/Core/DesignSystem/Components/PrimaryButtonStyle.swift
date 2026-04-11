import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Sizing.defaultButtonHeight)
            .background(isEnabled ? DesignSystem.Colors.brandPrimary : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.Radius.card)
            .opacity(configuration.isPressed ? DesignSystem.Animation.pressedOpacity : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

#Preview {
    Button("primary", action: {})
        .buttonStyle(.primary)
}
