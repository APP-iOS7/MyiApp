import DesignSystem
import Domain
import SwiftUI

struct FailureSection: View {
    let failure: CryAnalysisFeature.Failure
    let onDismiss: () -> Void

    private var message: String {
        switch failure {
        case .recordingFailed: "녹음을 시작할 수 없어요. 잠시 후 다시 시도해 주세요."
        case .analysisFailed: "분석에 실패했어요. 다시 시도해 주세요."
        }
    }

    var body: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.l)
            Spacer()
            Button("돌아가기", action: onDismiss)
                .buttonStyle(.primary)
        }
        .padding(Spacing.m)
    }
}
