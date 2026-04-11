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
        /// 보조 또는 비활성 텍스트/아이콘 색상
        public static let textSecondary = Color.gray.opacity(0.5)
        /// 선택된 상태의 강조 색상 (시스템 AccentColor 사용)
        public static let accent = Color.accentColor
        /// 앱의 기본 배경색 (시스템 그룹 배경색)
        public static let backgroundPrimary = Color(UIColor.systemGroupedBackground)

        // MARK: - 브랜드/공통 색상 (Assets 연결)

        /// 브랜드 프라이머리 컬러 (AccentColor와 동일)
        public static let brandPrimary = Color.accentColor
        /// 브랜드 프라이머리 다크 컬러
        public static let brandPrimaryDark = MyiAppAsset.BrandColors.clrBrandSharkPrimaryDark.swiftUIColor
        /// 브랜드 프라이머리 라이트 컬러
        public static let brandPrimaryLight = MyiAppAsset.BrandColors.clrBrandSharkPrimaryLight.swiftUIColor

        /// 앱의 메인 런칭 배경색
        public static let launchBackground = Color(.CommonColors.clrCommonLaunchBg)
        /// 앱의 메인 런칭 텍스트색
        public static let launchText = Color(.CommonColors.clrCommonLaunchText)
    }
}
