import SwiftUI

public struct ScreenTitle<Trailing: View>: View {
    public let title: String
    public let trailing: Trailing

    public init(_ title: String, @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .bold()
            Spacer()
            trailing
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ScreenTitle("육아 수첩")

        ScreenTitle("울음 분석") {
            Image(systemName: "list.bullet")
                .font(.title2)
        }

        ScreenTitle("기록 분석") {
            HStack(spacing: 16) {
                Image(systemName: "chart.xyaxis.line")
                Image(systemName: "square.and.arrow.up")
            }
            .font(.title2)
        }
    }
    .padding()
}
