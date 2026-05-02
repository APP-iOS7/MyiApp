import ComposableArchitecture
import DesignSystem
import Domain
import PhotosUI
import SwiftUI

public struct BabyProfileView: View {
    @Bindable var store: StoreOf<BabyProfileFeature>

    public init(store: StoreOf<BabyProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.m) {
            avatar
            infoCard
            Spacer()
        }
        .padding(Spacing.m)
        .labeledContentStyle(RowLabeledContentStyle())
        .background(Color.Semantic.screenBackground.ignoresSafeArea())
        .navigationTitle("아기 정보")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(
            isPresented: $store.isPickerPresented,
            selection: $store.pickerItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .confirmationDialog(
            "프로필 사진",
            isPresented: $store.isPhotoActionDialogPresented,
            titleVisibility: .visible
        ) {
            Button("라이브러리에서 선택") { store.send(.pickFromLibraryTapped) }
            Button("삭제", role: .destructive) { store.send(.deletePhotoTapped) }
            Button("취소", role: .cancel) {}
        }
        .loadingOverlay(isPresented: store.isUploading)
        .alert($store.scope(state: \.alert, action: \.alert))
        .task {
            await store.send(.task).finish()
        }
    }
}

private extension BabyProfileView {
    var avatar: some View {
        Button { store.send(.photoTapped) } label: {
            avatarImage
        }
        .buttonStyle(NoHighlightButtonStyle())
    }

    @ViewBuilder
    var avatarImage: some View {
        if let url = store.baby.profileImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image.resizable().scaledToFill()
                default:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.Semantic.secondaryText)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.Semantic.secondaryText)
        }
    }

    var infoCard: some View {
        SectionCard(spacing: 0) {
            Button { store.send(.nameRowTapped) } label: {
                LabeledContent {
                    HStack(spacing: Spacing.s) {
                        Text(store.baby.name)
                            .foregroundColor(.Semantic.secondaryText)
                        RowChevron()
                    }
                } label: {
                    Text("이름 / 태명")
                        .foregroundColor(.Semantic.sectionHeading)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())

            Button { store.send(.birthDateRowTapped) } label: {
                LabeledContent {
                    HStack(spacing: Spacing.s) {
                        Text(store.baby.birthDate.formatted(date: .long, time: .omitted))
                            .foregroundColor(.Semantic.secondaryText)
                        RowChevron()
                    }
                } label: {
                    Text("출생일")
                        .foregroundColor(.Semantic.sectionHeading)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())

            Button { store.send(.genderRowTapped) } label: {
                LabeledContent {
                    HStack(spacing: Spacing.s) {
                        Text(store.baby.gender.displayName)
                            .foregroundColor(.Semantic.secondaryText)
                        RowChevron()
                    }
                } label: {
                    Text("성별")
                        .foregroundColor(.Semantic.sectionHeading)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())

            Button { store.send(.bloodTypeRowTapped) } label: {
                LabeledContent {
                    HStack(spacing: Spacing.s) {
                        Text(store.baby.bloodType.rawValue)
                            .foregroundColor(.Semantic.secondaryText)
                        RowChevron()
                    }
                } label: {
                    Text("혈액형")
                        .foregroundColor(.Semantic.sectionHeading)
                }
            }
            .buttonStyle(NoHighlightButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        BabyProfileView(
            store: Store(
                initialState: BabyProfileFeature.State(
                    baby: Baby(
                        name: "꼬미",
                        birthDate: Calendar.current.date(byAdding: .day, value: -100, to: Date()) ?? Date(),
                        gender: .female,
                        bloodType: .a,
                        mainCaregiverID: "preview"
                    )
                )
            ) {
                BabyProfileFeature()
            }
        )
    }
}
