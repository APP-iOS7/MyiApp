import SwiftUI

extension DesignSystem {
    /// 색상에 대한 디자인 토큰 정의입니다.
    public enum Colors {
        // MARK: - Semantic Colors (의미론적 색상)

        /// 버튼의 기본 배경색 (기본 White)
        public static let buttonBackground = Color.white
        /// 버튼의 테두리 색상 (기본 Black)
        public static let buttonBorder = Color.black
        /// 기본 텍스트 색상 (기본 Black)
        public static let textPrimary = Color.black

        // MARK: - 브랜드/공통 색상 (Assets 연결)

        /// 앱의 메인 런칭 배경색
        public static let launchBackground = Color(.CommonColors.clrCommonLaunchBg)
        /// 앱의 메인 런칭 텍스트색
        public static let launchText = Color(.CommonColors.clrCommonLaunchText)
    }
}
