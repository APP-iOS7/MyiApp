import SwiftUI

public struct GoogleSignInButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                Image.Logos.google
                    .resizable()
                    .scaledToFit()
                    .frame(width: IconSize.s, height: IconSize.s)
                Text("Sign in with Google")
                    .font(.Style.button)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: ButtonSize.height)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.s))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.s)
                .stroke(.black, lineWidth: 1)
        )
    }
}

#Preview {
    GoogleSignInButton {}
        .padding()
}
