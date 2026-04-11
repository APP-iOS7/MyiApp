import SwiftUI

/// 디자인 시스템의 공통 밑줄형 텍스트 필드 컴포넌트입니다.
public struct UnderlinedTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let keyboardType: UIKeyboardType
    private let suffix: String?
    private let showClearButton: Bool
    private let onClear: (() -> Void)?

    public init(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        suffix: String? = nil,
        showClearButton: Bool = false,
        onClear: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        _text = text
        self.keyboardType = keyboardType
        self.suffix = suffix
        self.showClearButton = showClearButton
        self.onClear = onClear
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.itemSpacing) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.system(size: DesignSystem.Typography.componentFontSize))
                .padding(.vertical, DesignSystem.Spacing.itemSpacing)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)

            if let suffix {
                Text(suffix)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .font(.system(size: DesignSystem.Typography.componentFontSize))
            }

            if showClearButton, !text.isEmpty {
                Button(action: { onClear?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(
            Divider()
                .background(DesignSystem.Colors.textPrimary.opacity(0.1)),
            alignment: .bottom
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        UnderlinedTextField(
            placeholder: "이름을 입력하세요",
            text: .constant("홍길동"),
            showClearButton: true
        )

        UnderlinedTextField(
            placeholder: "키를 입력하세요",
            text: .constant("170"),
            keyboardType: .decimalPad,
            suffix: "cm",
            showClearButton: true
        )

        UnderlinedTextField(
            placeholder: "Placeholder",
            text: .constant(""),
            showClearButton: false
        )
    }
    .padding()
    .background(DesignSystem.Colors.backgroundPrimary)
}
