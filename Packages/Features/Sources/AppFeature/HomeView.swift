import ComposableArchitecture
import SwiftUI

public struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("환영합니다")
                    .font(.title.bold())
                if let displayName = store.session.displayName, !displayName.isEmpty {
                    Text(displayName)
                }
                if let email = store.session.email, !email.isEmpty {
                    Text(email)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                Button("로그아웃") {
                    store.send(.signOutTapped)
                }
                .buttonStyle(.borderedProminent)

                Button("계정 삭제", role: .destructive) {
                    store.send(.deleteAccountTapped)
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
        .disabled(store.isProcessing)
        .overlay {
            if store.isProcessing {
                ProgressView()
            }
        }
    }
}
