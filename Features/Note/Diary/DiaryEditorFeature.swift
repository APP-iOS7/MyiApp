import ComposableArchitecture
import Domain
import Foundation
import PhotosUI
import SwiftUI

@Reducer
public struct DiaryEditorFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String
        public var description: String
        public var date: Date
        public var pickerItems: [PhotosPickerItem]
        public var photos: [DiaryPhoto]

        public init(
            date: Date = Date(),
            title: String = "",
            description: String = "",
            pickerItems: [PhotosPickerItem] = [],
            photos: [DiaryPhoto] = []
        ) {
            self.date = date
            self.title = title
            self.description = description
            self.pickerItems = pickerItems
            self.photos = photos
        }

        public var canSave: Bool { !title.isEmpty }

        public var navigationTitle: String {
            Calendar.current.isDateInToday(date) ? "오늘의 일지" : "지난 일지"
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case removePhotoButtonTapped(DiaryPhoto.ID)
        case cancelButtonTapped
        case saveButtonTapped
        case _internal(Internal)
        case delegate(Delegate)

        public enum Internal {
            case photosLoaded([DiaryPhoto])
        }

        public enum Delegate: Equatable {
            case saved(Note)
            case cancelled
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.pickerItems):
                let currentIDs = state.pickerItems.compactMap(\.itemIdentifier)
                let existingByID = Dictionary(
                    uniqueKeysWithValues: state.photos.map { ($0.id, $0) }
                )
                state.photos = currentIDs.compactMap { existingByID[$0] }

                let newItems = state.pickerItems.filter { item in
                    guard let id = item.itemIdentifier else { return false }
                    return existingByID[id] == nil
                }
                return .run { send in
                    var loaded: [DiaryPhoto] = []
                    for item in newItems {
                        guard let id = item.itemIdentifier else { continue }
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            loaded.append(DiaryPhoto(id: id, data: data))
                        }
                    }
                    await send(._internal(.photosLoaded(loaded)))
                }

            case let ._internal(.photosLoaded(loaded)):
                let existingIDs = Set(state.photos.map(\.id))
                state.photos.append(contentsOf: loaded.filter { !existingIDs.contains($0.id) })
                return .none

            case let .removePhotoButtonTapped(id):
                state.photos.removeAll { $0.id == id }
                state.pickerItems.removeAll { $0.itemIdentifier == id }
                return .none

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

            case .saveButtonTapped:
                // TODO: photos data → Firebase Storage 업로드 후 URL로 변환 (현재는 placeholder)
                let placeholder = URL(string: "https://picsum.photos/200")
                let imageURLs = placeholder.map { Array(repeating: $0, count: state.photos.count) } ?? []
                let note = Note(
                    kind: .diary,
                    title: state.title,
                    description: state.description,
                    date: state.date,
                    imageURLs: imageURLs
                )
                return .send(.delegate(.saved(note)))

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
    }
}
