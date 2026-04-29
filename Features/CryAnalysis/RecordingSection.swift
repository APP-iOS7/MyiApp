import DesignSystem
import SwiftUI

struct RecordingSection: View {
    let volume: Float
    let progress: Double
    let onCancel: () -> Void

    private var remainingSeconds: Int {
        max(0, Int(ceil((1 - progress) * 7)))
    }

    var body: some View {
        VStack(spacing: Spacing.l) {
            Spacer()

            VolumeMeter(level: volume)

            Text("녹음 중")
                .font(.title2.weight(.semibold))

            Text("\(remainingSeconds)초 남음")
                .font(.body)
                .foregroundColor(.Semantic.secondaryText)
                .monospacedDigit()

            Spacer()

            ProgressBar(ratio: progress, tintColor: .Semantic.primaryAction)

            Button("취소", action: onCancel)
                .buttonStyle(.primary)
        }
        .padding(Spacing.m)
    }
}

#Preview("Recording") {
    RecordingSection(volume: 0.6, progress: 0.4, onCancel: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Semantic.screenBackground)
}
