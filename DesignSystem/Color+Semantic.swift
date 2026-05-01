import SwiftUI

public extension Color {
    enum Semantic {
        public static let launchText = Color(light: Color(Asset.Tokens.brown700), dark: .white)
        public static let launchBackground = Color(light: Color(Asset.Tokens.blue50), dark: Color(Asset.Tokens.blue900))
        public static let primaryAction = Color(light: Color(Asset.Tokens.blue500), dark: Color(Asset.Tokens.blue650))
        public static let sectionHeading = Color.primary.opacity(0.8)
        public static let secondaryText = Color.primary.opacity(0.6)
        public static let divider = Color.primary.opacity(0.8)
        public static let screenBackground = Color(light: Color(Asset.Tokens.gray50), dark: .black)
        public static let progressTrack = Color(light: Color(Asset.Tokens.gray200), dark: Color(Asset.Tokens.gray850))
        public static let progressMarker = Color(light: Color(Asset.Tokens.gray400), dark: Color(Asset.Tokens.gray400))

        // 통계 카테고리 (레거시 RecordColors 매핑)
        public static let feeding = Color(light: Color(Asset.Tokens.pink450), dark: Color(Asset.Tokens.pink450))
        public static let potty = Color(light: Color(Asset.Tokens.brown400), dark: Color(Asset.Tokens.brown400))
        public static let sleep = Color(light: Color(Asset.Tokens.yellow450), dark: Color(Asset.Tokens.yellow450))
        public static let bath = Color(light: Color(Asset.Tokens.blue300), dark: Color(Asset.Tokens.blue300))
        public static let snack = Color(light: Color(Asset.Tokens.purple350), dark: Color(Asset.Tokens.purple350))
        public static let growth = Color(light: Color(Asset.Tokens.green150), dark: Color(Asset.Tokens.green150))
        public static let health = Color(light: Color(Asset.Tokens.blueGray400), dark: Color(Asset.Tokens.blueGray400))
    }
}
