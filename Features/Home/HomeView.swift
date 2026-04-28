import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    let store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                BabyInfoCard(baby: store.baby)
            }
            .padding(Spacing.m)
        }
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }
}
