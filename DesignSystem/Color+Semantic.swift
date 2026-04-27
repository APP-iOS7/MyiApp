import SwiftUI

public extension Color {
    enum Semantic {
        public static let launchText = Color(light: .Token.brown700, dark: .white)
        public static let launchBackground = Color(light: .Token.blue50, dark: .Token.blue900)
        public static let primaryAction = Color(light: .Token.blue500, dark: .Token.blue650)
        public static let sectionHeading = Color.primary.opacity(0.8)
        public static let secondaryText = Color.primary.opacity(0.6)
        public static let divider = Color.primary.opacity(0.8)
        public static let screenBackground = Color(light: .Token.gray50, dark: .black)
    }
}
