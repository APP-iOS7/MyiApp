import SwiftUI

public struct AppleSignInButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 18))
                Text("Sign in with Apple")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
