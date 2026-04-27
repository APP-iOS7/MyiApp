import SwiftUI

public struct AppleSignInButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                Image(systemName: "apple.logo")
                    .font(.system(size: IconSize.s))
                Text("Sign in with Apple")
                    .font(.Style.button)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: ButtonSize.height)
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: Radius.s))
    }
}

#Preview {
    AppleSignInButton {}
        .padding()
}
