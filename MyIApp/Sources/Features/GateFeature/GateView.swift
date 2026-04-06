import ComposableArchitecture
import SwiftUI

struct GateView: View {
    let store: StoreOf<GateFeature>

    var body: some View {
        switch store.state {
        case .loading: ProgressView()
        case .login: EmptyView()
        case .main: EmptyView()
        }
    }
}
