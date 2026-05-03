import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct CryRecordListView: View {
    let store: StoreOf<CryRecordListFeature>

    public init(store: StoreOf<CryRecordListFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.records.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("분석 결과")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.send(.task).finish() }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "분석 결과가 없습니다",
            systemImage: "magnifyingglass",
            description: Text("분석을 완료하면 결과가 이곳에 표시됩니다.")
        )
    }

    private var list: some View {
        List(store.records) { record in
            CryRecordRow(record: record)
                .listRowBackground(Color.Semantic.screenBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.m, bottom: Spacing.xs, trailing: Spacing.m))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("삭제", systemImage: "trash", role: .destructive) {
                        store.send(.deleteTapped(record.id))
                    }
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
