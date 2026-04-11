import ComposableArchitecture
import SwiftUI

struct RegistrationTypeRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .appComponentStyle()

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title2)
                .foregroundColor(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.rowHorizontalPadding)
        .padding(.vertical, DesignSystem.Spacing.rowVerticalPadding)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

#Preview {
    RegistrationTypeRow(title: "새로운 아이 정보 등록", isSelected: true, action: {})
    RegistrationTypeRow(title: "새로운 아이 정보 등록", isSelected: false, action: {})
}
