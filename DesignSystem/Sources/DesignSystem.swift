import SwiftUI

public enum DesignSystem {
    private final class BundleToken {}
    public static let bundle = Bundle(for: BundleToken.self)

    public enum Spacing {
        /// 8
        public static let small: CGFloat = 8
        /// 10
        public static let extraSmall: CGFloat = 10
        /// 12
        public static let medium: CGFloat = 12
        /// 16 (SwiftUI default padding)
        public static let defaultPadding: CGFloat = 16
        /// 30
        public static let large: CGFloat = 30
        /// 40
        public static let authHorizontal: CGFloat = 40
    }

    public enum Size {
        /// 100
        public static let logo: CGFloat = 100
        /// 12
        public static let cornerRadius: CGFloat = 12
        /// 1
        public static let lineWidth: CGFloat = 1
    }

    public enum Colors {
        public static let brandPink: Color = .pink
        public static let error: Color = .red
        /// black.opacity(0.1)
        public static let border: Color = .black.opacity(0.1)

        // Legacy Colors
        public static let launchScreen: Color = .init("LaunchScreenColor", bundle: DesignSystem.bundle)
        public static let launchScreenText: Color = .init("LaunchScreenTextColor", bundle: DesignSystem.bundle)
    }

    public enum Icons {
        /// heart.fill
        public static let logo: String = "heart.fill"
        /// g.circle.fill
        public static let google: String = "g.circle.fill"
        /// apple.logo
        public static let apple: String = "apple.logo"

        // Legacy Icons
        public static let googleLogo: String = "google-logo-icon"
        public static let launchScreenImage: String = "launchScreenImage"
    }
}
