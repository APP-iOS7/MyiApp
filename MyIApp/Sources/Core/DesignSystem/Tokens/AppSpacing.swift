import Foundation

extension DesignSystem {
    /// 여백 및 간격에 대한 토큰 정의입니다.
    public enum Spacing {
        /// 시스템 기본 패딩 (기본 16)
        public static let defaultPadding: CGFloat = 16
        /// 컴포넌트 간의 가로 패딩 (기본 50)
        public static let horizontalPadding: CGFloat = 50
        /// 컴포넌트 간의 수직 간격 (기본 12)
        public static let componentVerticalSpacing: CGFloat = 12
        /// 컴포넌트 내부의 수직 패딩 (기본 13)
        public static let internalVerticalPadding: CGFloat = 13
        /// 컴포넌트 내부 아이템 간의 간격 (기본 8)
        public static let itemSpacing: CGFloat = 8
    }
}
