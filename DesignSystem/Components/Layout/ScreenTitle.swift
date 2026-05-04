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
