import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct RegisterMethodPickerView: View {
    @Bindable var store: StoreOf<BabyRegisterFeature>

    public init(store: StoreOf<BabyRegisterFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("등록 방식을 선택해주세요")
                    .font(.title.bold())
                    .foregroundColor(.primary.opacity(0.8))
                    .padding(.top, Spacing.l)
                    .padding(.horizontal, Spacing.m)

                VStack(spacing: 0) {
                    methodRow(
                        title: "새로운 아이 정보 등록",
                        method: .newBaby
                    )
                    methodRow(
                        title: "초대받은 아이 등록",
                        method: .existingBaby
                    )
                }
            }
            .padding(.bottom, Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.l)
                    .fill(Color(uiColor: .tertiarySystemBackground))
            )

            Spacer()

            Button("다음") {
                store.send(.nextTapped)
            }
            .buttonStyle(.primary)
            .disabled(store.selectedMethod == nil)
        }
        .padding(Spacing.m)
    }

    private func methodRow(title: String, method: BabyRegisterFeature.Method) -> some View {
        HStack {
            Text(title)
                .font(.title3)

            Spacer()

            Image(systemName: store.selectedMethod == method
                ? "checkmark.circle.fill"
                : "checkmark.circle")
                .font(.title2)
                .foregroundColor(store.selectedMethod == method
                    ? .Semantic.primaryAction
                    : .primary.opacity(0.6))
        }
        .padding(Spacing.m)
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.methodSelected(method))
        }
    }
}

#Preview {
    RegisterMethodPickerView(
        store: Store(initialState: BabyRegisterFeature.State()) {
            BabyRegisterFeature()
        }
    )
}
