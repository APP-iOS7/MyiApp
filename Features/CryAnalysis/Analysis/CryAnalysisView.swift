import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct CryAnalysisView: View {
    @Bindable var store: StoreOf<CryAnalysisFeature>

    public init(store: StoreOf<CryAnalysisFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            switch store.stage {
            case .recording:
                RecordingSection(
                    volume: store.volume,
                    progress: store.progress,
                    onCancel: { store.send(.view(.cancelTapped)) }
                )

            case let .result(display):
                ResultSection(
                    display: display,
                    onDismiss: { store.send(.view(.dismissTapped)) }
                )

            case let .failure(failure):
                FailureSection(
                    failure: failure,
                    onDismiss: { store.send(.view(.dismissTapped)) }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .task { await store.send(.view(.task)).finish() }
    }
}
