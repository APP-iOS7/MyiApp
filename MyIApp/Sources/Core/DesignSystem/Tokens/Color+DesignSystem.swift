import SwiftUI

extension Color {
    // MARK: - Legacy Compatibility

    public static let customBackground = DesignSystem.Colors.backgroundPrimary
    public static let sharkPrimaryLight = DesignSystem.Colors.brandPrimaryLight
    public static let sharksSadowTone = Color.gray.opacity(0.2)
    public static let button = DesignSystem.Colors.brandPrimary

    // MARK: - Record Colors

    public static let food = Color(red: 0.976, green: 0.761, blue: 0.769)
    public static let diaper = Color(red: 0.812, green: 0.922, blue: 0.984)
    public static let sleep = Color(red: 0.655, green: 0.655, blue: 0.867)
    public static let heightWeight = Color(red: 0.984, green: 0.898, blue: 0.757)
    public static let bath = Color(red: 0.757, green: 0.898, blue: 0.984)
    public static let snack = Color(red: 0.984, green: 0.827, blue: 0.757)
    public static let health = Color(red: 0.984, green: 0.757, blue: 0.757)
    public static let potty = Color(red: 0.827, green: 0.984, blue: 0.757)
}
