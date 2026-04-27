import SwiftUI

public struct GoogleSignInButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image.Logos.google
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("Sign in with Google")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.black, lineWidth: 1)
        )
    }
}
