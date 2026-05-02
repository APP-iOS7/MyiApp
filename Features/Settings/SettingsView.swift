import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack(spacing: Spacing.m) {
                    accountSection
                    personalSettingsSection
                    legalSection
                    miscSection
                    accountActionsSection
                }
                .padding(Spacing.m)
                .labelStyle(IconLabelStyle())
                .labeledContentStyle(RowLabeledContentStyle())
            }
            .background(Color.Semantic.screenBackground.ignoresSafeArea())
            .loadingOverlay(isPresented: store.isLoading)
            .alert($store.scope(state: \.alert, action: \.alert))
        } destination: { store in
            switch store.case {
            case let .accountEdit(store):
                AccountEditView(store: store)
            case let .babyProfile(store):
                BabyProfileView(store: store)
            case let .nameEdit(store):
                BabyNameEditView(store: store)
            case let .birthDateEdit(store):
                BabyBirthDateEditView(store: store)
            case let .genderEdit(store):
                BabyGenderEditView(store: store)
            case let .bloodTypeEdit(store):
                BabyBloodTypeEditView(store: store)
            case let .babyRegister(store):
                RegisterMethodPickerView(store: store)
            }
        }
    }
}

private extension SettingsView {
    var accountSection: some View {
        NavigationLink(state: SettingsFeature.Path.State.accountEdit(
            AccountEditFeature.State(originalName: store.caregiver.displayName)
        )) {
            SectionCard(spacing: 0) {
                HStack(spacing: Spacing.m) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.Semantic.secondaryText)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(store.displayName)
                            .font(.headline)
                            .foregroundColor(.Semantic.sectionHeading)
                        Text(store.providerText)
                            .font(.subheadline)
                            .foregroundColor(.Semantic.secondaryText)
                    }

                    Spacer()

                    RowChevron()
                }
            }
        }
        .buttonStyle(NoHighlightButtonStyle())
    }

    var personalSettingsSection: some View {
        SectionCard(title: "개인 설정", spacing: 0) {
            DisclosureGroup {
                ForEach(store.babies) { baby in
                    NavigationLink(state: SettingsFeature.Path.State.babyProfile(BabyProfileFeature.State(baby: baby))) {
                        LabeledContent {
                            RowChevron()
                        } label: {
                            Label(baby.name, systemImage: "arrow.turn.down.right")
                                .foregroundColor(.Semantic.secondaryText)
                        }
                    }
                    .buttonStyle(NoHighlightButtonStyle())
                }
                NavigationLink(state: SettingsFeature.Path.State.babyRegister(BabyRegisterFeature.State())) {
                    LabeledContent {
                        RowChevron()
                    } label: {
                        Label("새로운 아기 프로필 등록", systemImage: "plus.circle.fill")
                            .foregroundColor(.Semantic.secondaryText)
                    }
                }
                .buttonStyle(NoHighlightButtonStyle())
            } label: {
                Label("아기 정보", icon: Image(Asset.Settings.babyInfo))
            }
            .disclosureGroupStyle(PlainDisclosureGroupStyle())
        }
    }

    var legalSection: some View {
        SectionCard(title: "개인 정보", spacing: 0) {
            NavigationLink { PrivacyPolicyView() } label: {
                LabeledContent {
                    RowChevron()
                } label: {
                    Label("개인 정보 처리 방침", icon: Image(Asset.Settings.privacy))
                }
            }
            .buttonStyle(NoHighlightButtonStyle())

            NavigationLink { TermsOfServiceView() } label: {
                LabeledContent {
                    RowChevron()
                } label: {
                    Label("이용 약관", icon: Image(Asset.Settings.agreement))
                }
            }
            .buttonStyle(NoHighlightButtonStyle())
        }
    }

    var miscSection: some View {
        SectionCard(title: "기타", spacing: 0) {
            LabeledContent {
                Text(store.appVersion)
                    .foregroundColor(.Semantic.secondaryText)
            } label: {
                Label("앱 버전", icon: Image(Asset.Settings.appVersion))
            }
        }
    }

    var accountActionsSection: some View {
        VStack(spacing: Spacing.s) {
            Button(role: .destructive) { store.send(.view(.signOutTapped)) } label: {
                Text("로그아웃")
                    .frame(maxWidth: .infinity)
            }
            .padding(Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.m)
                    .fill(Color(uiColor: .tertiarySystemBackground))
            )

            Button { store.send(.view(.deleteAccountTapped)) } label: {
                Text("계정 삭제")
                    .font(.caption2)
                    .foregroundColor(.Semantic.secondaryText)
                    .underline()
                    .padding(.vertical, Spacing.m)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(
                initialState: SettingsFeature.State(
                    session: Session(
                        uid: "user-123",
                        email: "parent@example.com",
                        providerIDs: ["apple.com"]
                    ),
                    caregiver: Caregiver(
                        id: "user-123",
                        displayName: "행복한 엄마",
                        createdAt: Date()
                    ),
                    babies: [
                        Baby(
                            id: UUID(),
                            name: "꼬미",
                            birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
                            gender: .female,
                            bloodType: .a,
                            mainCaregiverID: "user-123"
                        ),
                        Baby(
                            id: UUID(),
                            name: "뚜비",
                            birthDate: Calendar.current.date(byAdding: .day, value: -300, to: Date())!,
                            gender: .male,
                            bloodType: .b,
                            mainCaregiverID: "user-123"
                        ),
                    ]
                )
            ) {
                SettingsFeature()
            }
        )
    }
}
