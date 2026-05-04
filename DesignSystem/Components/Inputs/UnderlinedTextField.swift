import SwiftUI
import UIKit

public struct UnderlinedTextField<Trailing: View>: View {
    private let placeholder: String
    @Binding private var text: String
    private let keyboardType: UIKeyboardType
    private let trailing: Trailing

    public init(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.placeholder = placeholder
        _text = text
        self.keyboardType = keyboardType
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: Spacing.s) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundColor(.Semantic.secondaryText)
                .font(.title2)
            trailing
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, Spacing.s)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.Semantic.divider)
        }
    }
}
