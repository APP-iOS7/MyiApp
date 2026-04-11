import SwiftUI

/// 디자인 시스템의 공통 체크마크 로우 컴포넌트입니다.
public struct CheckmarkRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        HStack {
            Text(title)
                .appComponentStyle()
                .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title2)
                .foregroundColor(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
        }
        .padding(.vertical, DesignSystem.Spacing.rowVerticalPadding)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

#Preview {
    VStack {
        CheckmarkRow(title: "선택된 아이템", isSelected: true, action: {})
        CheckmarkRow(title: "선택되지 않은 아이템", isSelected: false, action: {})
    }
    .background(DesignSystem.Colors.backgroundPrimary)
}
