import SwiftUI

public struct SignInButton: View {
    private let title: String
    private let image: ImageResource
    private let action: () -> Void

    public init(
        title: String,
        image: ImageResource,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.itemSpacing) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DesignSystem.Typography.iconSize, height: DesignSystem.Typography.iconSize)

                Text(title)
                    .font(.system(size: DesignSystem.Typography.componentFontSize, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, DesignSystem.Spacing.defaultPadding)
            .padding(.vertical, DesignSystem.Spacing.internalVerticalPadding)
        }
        .background(DesignSystem.Colors.buttonBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .stroke(DesignSystem.Colors.buttonBorder)
        )
        .padding(.horizontal, DesignSystem.Spacing.horizontalPadding)
    }
}

#Preview {
    VStack(spacing: 20) {
        SignInButton(
            title: "Sign in with Google",
            image: .AuthIcons.icAuthGoogleLogo,
            action: {}
        )

        SignInButton(
            title: "Sign in with Apple",
            image: .AuthIcons.icAuthAppleLogo,
            action: {}
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
