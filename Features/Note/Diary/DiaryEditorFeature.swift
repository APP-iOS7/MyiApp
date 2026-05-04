import ComposableArchitecture
import Domain
import Foundation
import PhotosUI
import Shared
import SwiftUI

@Reducer
public struct DiaryEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public var babyID: UUID
        public var title: String
        public var description: String
        public var date: Date
        public var isPickerPresented: Bool
        public var pickerItems: [PhotosPickerItem]
        public var photos: [DiaryPhoto]
        public var isSaving: Bool

        public init(
            babyID: UUID,
            date: Date = Date(),
            title: String = "",
            description: String = "",
            isPickerPresented: Bool = false,
            pickerItems: [PhotosPickerItem] = [],
            photos: [DiaryPhoto] = [],
            isSaving: Bool = false
        ) {
            self.babyID = babyID
            self.date = date
            self.title = title
            self.description = description
            self.isPickerPresented = isPickerPresented
            self.pickerItems = pickerItems
            self.photos = photos
            self.isSaving = isSaving
        }

        public var canSave: Bool { !title.isEmpty && !isSaving }

        public var navigationTitle: String {
            Calendar.current.isDateInToday(date) ? "오늘의 일지" : "지난 일지"
        }
    }

    public enum Action: BindableAction {
        public enum ViewAction: Equatable {
            case removePhotoButtonTapped(DiaryPhoto.ID)
            case cancelButtonTapped
            case saveButtonTapped
        }

        public enum InternalAction {
            case photoLoaded(DiaryPhoto)
            case saveCompleted
            case saveFailed(NoteError)
            case uploadFailed(StorageError)
        }

        public enum Delegate: Equatable {
            case saved
            case cancelled
        }

        case view(ViewAction)
        case _internal(InternalAction)
        case delegate(Delegate)

        case binding(BindingAction<State>)
    }

    @Dependency(\.noteClient) var noteClient
    @Dependency(\.storageClient) var storageClient
    @Dependency(\.authClient) var authClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.pickerItems):
                let selectedIDs = state.pickerItems.compactMap(\.itemIdentifier)
                let nilIdentifierCount = state.pickerItems.count - selectedIDs.count
                let selectedIDSet = Set(selectedIDs)
                state.photos.removeAll { !selectedIDSet.contains($0.id) }
                let existingIDs = Set(state.photos.map(\.id))
                let newItems = state.pickerItems.filter { item in
                    guard let id = item.itemIdentifier else { return false }

                    return !existingIDs.contains(id)
                }
                AppLogger
                    .info(
                        "pickerItems changed: total=\(state.pickerItems.count) nilID=\(nilIdentifierCount) selected=\(selectedIDs.count) existing=\(existingIDs.count) new=\(newItems.count)"
                    )
                return .run { send in
                    for item in newItems {
                        if let photo = await DiaryPhoto.load(from: item) {
                            await send(._internal(.photoLoaded(photo)))
                        }
                    }
                }

            case let ._internal(.photoLoaded(photo)):
                guard !state.photos.contains(where: { $0.id == photo.id }) else {
                    AppLogger.debug("photoLoaded skipped (duplicate): \(photo.id)")
                    return .none
                }

                AppLogger.info("photoLoaded id=\(photo.id) bytes=\(photo.data.count)")
                state.photos.append(photo)
                return .none

            case let .view(.removePhotoButtonTapped(id)):
                state.photos.removeAll { $0.id == id }
                state.pickerItems.removeAll { $0.itemIdentifier == id }
                return .none

            case .view(.cancelButtonTapped):
                return .send(.delegate(.cancelled))

            case .view(.saveButtonTapped):
                guard !state.isSaving else { return .none }
                guard let session = authClient.current() else {
                    AppLogger.error("save aborted: not authenticated")
                    state.isSaving = false
                    return .send(._internal(.saveFailed(.unauthorized)))
                }

                state.isSaving = true
                let noteID = UUID()
                let creatorID = session.uid
                let title = state.title
                let description = state.description
                let date = state.date
                let photoDatas = state.photos.map(\.data)
                AppLogger.info("save start noteID=\(noteID) creatorID=\(creatorID) photos=\(photoDatas.count)")
                return .run { [storageClient, noteClient, babyID = state.babyID] send in
                    let imageURLs: [URL]
                    do throws(StorageError) {
                        imageURLs = try await uploadDiaryPhotos(
                            storageClient: storageClient,
                            babyID: babyID,
                            noteID: noteID,
                            photos: photoDatas
                        )
                    } catch {
                        AppLogger.error("upload failed: \(error)")
                        await send(._internal(.uploadFailed(error)))
                        return
                    }

                    let note = Note(
                        id: noteID,
                        creatorID: creatorID,
                        kind: .diary,
                        title: title,
                        description: description,
                        date: date,
                        imageURLs: imageURLs
                    )
                    do throws(NoteError) {
                        try await noteClient.addNote(babyID, note)
                    } catch {
                        AppLogger.error("addNote failed: \(error), rollback \(imageURLs.count) photos")
                        // TODO: rollback 정책 결정 (best-effort silent / logger 도입 / 제거) — Todo.md
                        for url in imageURLs {
                            do throws(StorageError) {
                                try await storageClient.deletePhoto(url)
                            } catch {
                                AppLogger.error("rollback delete failed: \(error) for \(url)")
                            }
                        }
                        await send(._internal(.saveFailed(error)))
                        return
                    }
                    AppLogger.info("save completed noteID=\(noteID)")
                    await send(._internal(.saveCompleted))
                }

            case ._internal(.saveCompleted):
                state.isSaving = false
                return .send(.delegate(.saved))

            case ._internal(.saveFailed):
                state.isSaving = false
                // TODO: alert 등 사용자 안내 (후속 작업)
                return .none

            case ._internal(.uploadFailed):
                state.isSaving = false
                // TODO: alert 등 사용자 안내 (후속 작업)
                return .none

            case .binding, .delegate:
                return .none
            }
        }
    }
}

extension DiaryEditorFeature {
    public static let maxPhotos = 10

    public struct DiaryPhoto: Equatable, Identifiable, Sendable {
        public let id: String
        public let data: Data

        public init(id: String, data: Data) {
            self.id = id
            self.data = data
        }

        static func load(from item: PhotosPickerItem) async -> DiaryPhoto? {
            guard let id = item.itemIdentifier else {
                AppLogger.error("itemIdentifier is nil")
                return nil
            }

            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    AppLogger.error("loadTransferable returned nil for \(id)")
                    return nil
                }

                AppLogger.debug("loaded id=\(id) bytes=\(data.count)")
                return DiaryPhoto(id: id, data: data)
            } catch {
                AppLogger.error("loadTransferable failed: \(error) for \(id)")
                return nil
            }
        }
    }
}

private func uploadDiaryPhotos(
    storageClient: StorageClient,
    babyID: UUID,
    noteID: UUID,
    photos: [Data]
) async throws(StorageError)
    -> [URL]
{
    AppLogger.info("uploadDiaryPhotos count=\(photos.count) babyID=\(babyID) noteID=\(noteID)")
    var uploaded: [URL] = []
    do throws(StorageError) {
        for (index, data) in photos.enumerated() {
            AppLogger.debug("upload \(index + 1)/\(photos.count) bytes=\(data.count)")
            let url = try await storageClient.uploadDiaryPhoto(babyID, noteID, data)
            uploaded.append(url)
        }
    } catch {
        AppLogger
            .error("uploadDiaryPhotos failed at index=\(uploaded.count): \(error), rollback \(uploaded.count) uploaded")
        // TODO: rollback 정책 결정 (best-effort silent / logger 도입 / 제거) — Todo.md
        for url in uploaded {
            do throws(StorageError) {
                try await storageClient.deletePhoto(url)
            } catch {
                AppLogger.error("rollback delete failed: \(error) for \(url)")
            }
        }
        throw error
    }
    AppLogger.info("uploadDiaryPhotos done count=\(uploaded.count)")
    return uploaded
}
