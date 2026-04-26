import ComposableArchitecture
import SwiftUI

public struct LoginView: View {
    @Bindable var store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("MyI")
                .font(.largeTitle.bold())
            Spacer()

            VStack(spacing: 12) {
                Button {
                    store.send(.signInWithAppleTapped)
                } label: {
                    Text("Apple로 계속하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    store.send(.signInWithGoogleTapped)
                } label: {
                    Text("Google로 계속하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1)
                        )
                }
            }

            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .disabled(store.isLoading)
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    LoginView(
        store: Store(initialState: AuthFeature.State()) {
            AuthFeature()
        }
    )
}
