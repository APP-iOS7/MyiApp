import SwiftUI

/// 대제목용 스타일 수식어입니다. (Size 28 + Bold + Primary Black)
public struct AppTitleStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: DesignSystem.Typography.titleFontSize))
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.Colors.textPrimary)
    }
}

/// 컴포넌트/목록 텍스트용 스타일 수식어입니다. (Size 18.5 + Primary Black)
public struct AppComponentStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: DesignSystem.Typography.componentFontSize))
            .foregroundColor(DesignSystem.Colors.textPrimary)
    }
}

/// 헤더 로고용 스타일 수식어입니다. (Size 60 + Bold + Primary Black)
public struct AppHeaderLogoStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: DesignSystem.Typography.headerLogoSize))
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.Colors.textPrimary)
    }
}

/// 섹션 타이틀용 스타일 수식어입니다. (componentFontSize + Bold + textPrimary)
public struct AppSectionTitleStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.system(size: DesignSystem.Typography.componentFontSize))
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.Colors.textPrimary.opacity(0.8))
    }
}
