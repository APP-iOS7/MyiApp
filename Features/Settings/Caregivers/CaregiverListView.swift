import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct CaregiverListView: View {
    @Bindable var store: StoreOf<CaregiverListFeature>

    public init(store: StoreOf<CaregiverListFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            if store.isMainCaregiver {
                Section {
                    ShareLink(
                        item: store.baby.id.uuidString,
                        subject: Text("육아 초대 코드"),
                        message: Text("이 코드를 공유해 양육자를 추가하세요.")
                    ) {
                        Text("초대 코드 공유")
                    }
                } footer: {
                    Text("초대 코드를 공유해 다른 양육자가 같은 아기 정보를 함께 관리할 수 있어요.")
                }
            }

            Section("연결된 양육자") {
                if store.caregivers.isEmpty {
                    Text("연결된 양육자가 없어요.")
                        .foregroundColor(.Semantic.secondaryText)
                }
                ForEach(store.caregivers) { caregiver in
                    CaregiverRow(
                        caregiver: caregiver,
                        isMain: caregiver.id == store.baby.mainCaregiverID,
                        isSelf: caregiver.id == store.currentUserID
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if canRemove(caregiver) {
                            Button(role: .destructive) {
                                store.send(.view(.removeTapped(caregiver.id)))
                            } label: {
                                Label("해제", systemImage: "person.fill.xmark")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("연결된 양육자")
        .navigationBarTitleDisplayMode(.inline)
        .alert($store.scope(state: \.alert, action: \.alert))
        .task {
            await store.send(.view(.task)).finish()
        }
    }

    private func canRemove(_ caregiver: Caregiver) -> Bool {
        store.isMainCaregiver
            && caregiver.id != store.baby.mainCaregiverID
            && caregiver.id != store.currentUserID
    }
}
