import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct CryAnalysisHomeView: View {
    @Bindable var store: StoreOf<CryAnalysisHomeFeature>

    public init(store: StoreOf<CryAnalysisHomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            introContent
        } destination: { childStore in
            CryAnalysisView(store: childStore)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private var introContent: some View {
        VStack(spacing: Spacing.m) {
            ScreenTitle("울음 분석")

            SectionCard(spacing: Spacing.xl) {
                Image(Asset.Analysis.processing)
                    .resizable()
                    .scaledToFit()

                VStack(spacing: Spacing.s) {
                    Text("시작 버튼을 누른 후")
                    Text("아이의 울음소리를 들려주세요")
                }
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity)

                VStack(spacing: Spacing.m) {
                    Text("녹음은 7초 동안 진행됩니다.")
                    Text("가장 뚜렷한 울음소리가 들릴 때 시작해 주세요.")
                    Text("정확한 분석을 위해 조용한 환경에서 녹음해 주세요.")
                }
                .font(.subheadline)
                .foregroundColor(.Semantic.secondaryText)
                .frame(maxWidth: .infinity)
            }

            Button("분석 시작") { store.send(.startTapped) }
                .buttonStyle(.primary)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }
}
