import Foundation

extension DesignSystem {
    /// 애니메이션 및 시각적 효과에 대한 토큰 정의입니다.
    public enum Animation {
        /// 기본 애니메이션 지속 시간 (기본 0.3)
        public static let defaultDuration: Double = 0.3
        /// 로딩 인디케이터 스케일 (기본 1.5)
        public static let loadingScale: CGFloat = 1.5
        /// 화면 오버레이 투명도 (기본 0.5)
        public static let overlayOpacity: Double = 0.5
        /// 버튼 눌림 효과 투명도 (기본 0.8)
        public static let pressedOpacity: Double = 0.8
    }
}
