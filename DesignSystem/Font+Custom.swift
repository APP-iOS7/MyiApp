import SwiftUI

public extension Font {
    enum Style {
        public static let button: Font = .system(size: 18, weight: .semibold)
        public static let brandTitle: Font = DesignSystemFontFamily.BmJuaOtf.regular.swiftUIFont(size: 60)
        public static let sectionTitle: Font = .title.bold()
        public static let sectionLabel: Font = .title3.bold()
    }
}
