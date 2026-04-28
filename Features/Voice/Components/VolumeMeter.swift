import DesignSystem
import Foundation
import SwiftUI

struct VolumeMeter: View {
    let level: Float // 0...1

    private var amplified: CGFloat {
        CGFloat(cbrt(max(0, min(1, level))))
    }

    var body: some View {
        GeometryReader { proxy in
            let available = min(proxy.size.width, proxy.size.height)
            let base = available * VolumeMeterLayout.baseRatio

            ZStack {
                Circle()
                    .fill(Color.Semantic.primaryAction.opacity(VolumeMeterLayout.outerOpacity))
                    .frame(width: base, height: base)
                    .scaleEffect(1 + amplified * VolumeMeterLayout.outerPulseBoost)

                Circle()
                    .fill(Color.Semantic.primaryAction.opacity(VolumeMeterLayout.midOpacity))
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

#Preview {
    VStack(spacing: 40) {
        VolumeMeter(level: 0.0)
        VolumeMeter(level: 0.3)
        VolumeMeter(level: 0.7)
        VolumeMeter(level: 1.0)
    }
    .padding()
}
