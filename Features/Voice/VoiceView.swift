import DesignSystem
import Domain
import SwiftUI

public struct VoiceView: View {
    public let baby: Baby?

    public init(baby: Baby?) {
        self.baby = baby
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            ScreenTitle("울음 분석") {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

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

            Button("분석 시작") {}
                .buttonStyle(.primary)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
    }
}

#Preview {
    VoiceView(baby: nil)
}
