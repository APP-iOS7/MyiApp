import SwiftUI

public extension Font {
    enum MyI {
        public static func bmjua(size: CGFloat) -> Font {
            .custom("BMJUAOTF", size: size)
        }
    }

    enum Style {
        public static let button: Font = .system(size: 18, weight: .semibold)
        public static let brandTitle: Font = .MyI.bmjua(size: 60)
    }
}
