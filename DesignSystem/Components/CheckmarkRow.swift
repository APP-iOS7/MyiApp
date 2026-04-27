import SwiftUI

public struct CheckmarkRow: View {
    private let title: String
    private let font: Font
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        title: String,
        font: Font = .title3,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(font)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .font(.title2)
                .foregroundColor(isSelected ? .Semantic.primaryAction : .primary.opacity(0.6))
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

#Preview {
    VStack(spacing: 0) {
        CheckmarkRow(title: "새로운 아이 정보 등록", isSelected: true) {}
        CheckmarkRow(title: "초대받은 아이 등록", isSelected: false) {}
    }
    .padding()
}
