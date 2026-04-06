import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var gate: GateFeature.State = .loading
    }

    enum Action {
        case gate(GateFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.gate, action: \.gate) {
            GateFeature()
        }
    }
}
