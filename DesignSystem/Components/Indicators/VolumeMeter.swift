import Foundation
import SwiftUI

public struct VolumeMeter: View {
    let level: Float // 0...1

    public init(level: Float) {
        self.level = level
    }

    private var amplified: CGFloat {
        CGFloat(cbrt(max(0, min(1, level))))
    }

    public var body: some View {
        GeometryReader { proxy in
            let available = min(proxy.size.width, proxy.size.height)
            let base = available * VolumeMeterLayout.baseRatio

            ZStack {
                Circle()
                    .fill(Color.Semantic.primaryAction.opacity(Opacity.track))
                    .frame(width: base, height: base)
                    .scaleEffect(1 + amplified * VolumeMeterLayout.outerPulseBoost)

                Circle()
                    .fill(Color.Semantic.primaryAction.opacity(Opacity.soft))
                    .frame(
                        width: base * VolumeMeterLayout.midRingRatio,
                        height: base * VolumeMeterLayout.midRingRatio
                    )
                    .scaleEffect(1 + amplified * VolumeMeterLayout.midPulseBoost)

                Circle()
                    .fill(Color.Semantic.primaryAction)
                    .frame(
                        width: base * VolumeMeterLayout.coreRatio,
                        height: base * VolumeMeterLayout.coreRatio
                    )
                    .scaleEffect(1 + amplified * VolumeMeterLayout.corePulseBoost)

                Image(systemName: "mic.fill")
                    .font(.system(size: base * VolumeMeterLayout.iconRatio))
                    .foregroundColor(.white)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .animation(.easeOut(duration: 0.1), value: amplified)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
