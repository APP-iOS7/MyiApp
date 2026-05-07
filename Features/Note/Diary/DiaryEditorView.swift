import ComposableArchitecture
import DesignSystem
import Domain
import PhotosUI
import SwiftUI

public struct DiaryEditorView: View {
    @Bindable var store: StoreOf<DiaryEditorFeature>

    public init(store: StoreOf<DiaryEditorFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoStrip
                }

                Section {
                    TextField("제목", text: $store.title)
                        .font(.title3.weight(.medium))
                    TextField("이 날의 일을 적어보세요", text: $store.description, axis: .vertical)
                        .lineLimit(3 ... 8)
                }
            }
            .navigationTitle(store.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { store.send(.view(.cancelButtonTapped)) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { store.send(.view(.saveButtonTapped)) }
                        .disabled(!store.canSave)
                }
            }
            .task { store.send(.view(.task)) }
        }
    }

    private var photoStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s) {
                Button {
                    store.isPickerPresented = true
                } label: {
                    AddPhotoLabel()
                }
                .buttonStyle(NoHighlightButtonStyle())

                ForEach(store.photos) { photo in
                    PhotoThumbnail(data: photo.data) {
                        store.send(.view(.removePhotoButtonTapped(photo.id)))
                    }
                }
            }
        }
        .photosPicker(
            isPresented: $store.isPickerPresented,
            selection: $store.pickerItems,
            maxSelectionCount: DiaryEditorFeature.maxPhotos,
            matching: .images,
            photoLibrary: .shared()
        )
    }
}
