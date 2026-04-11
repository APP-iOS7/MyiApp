import SwiftUI

/// 디자인 시스템의 전체 네임스페이스입니다.
public enum DesignSystem {
    // 공용 토큰들을 위한 공간입니다.
}

extension View {
    /// 대제목 스타일을 적용합니다. (Size 28, Bold, Primary Black)
    public func appTitleStyle() -> some View {
        modifier(AppTitleStyle())
    }

    /// 목록 또는 컴포넌트 내 텍스트 스타일을 적용합니다. (Size 18.5, Primary Black)
    public func appComponentStyle() -> some View {
        modifier(AppComponentStyle())
    }

    public func appHeaderLogoStyle() -> some View {
        modifier(AppHeaderLogoStyle())
    }

    /// 섹션 타이틀 텍스트 스타일을 적용합니다.
    public func appSectionTitleStyle() -> some View {
        modifier(AppSectionTitleStyle())
    }
}
