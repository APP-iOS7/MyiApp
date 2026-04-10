import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: DesignSystem.Typography.componentFontSize, weight: .bold))
            .foregroundColor(DesignSystem.Colors.buttonBackground)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Sizing.defaultButtonHeight)
            .cornerRadius(DesignSystem.Radius.medium)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}
