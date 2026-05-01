import ComposableArchitecture
import Domain
import Foundation
import PhotosUI
import Shared
import SwiftUI

@Reducer
public struct BabyProfileFeature {
    @ObservableState
    public struct State: Equatable {
        public var baby: Baby
        public var pickerItem: PhotosPickerItem?
        public var isPickerPresented: Bool = false
        public var isPhotoActionDialogPresented: Bool = false
        public var isUploading: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?

        public init(baby: Baby) {
            self.baby = baby
        }
    }

    public enum Action: BindableAction {
        public enum InternalAction {
            case babyUpdated(Baby)
            case photoUploaded(URL, replacing: URL?)
            case photoDeleted
            case photoActionFailed
        }
        public enum DelegateAction: Equatable {
            case editNameTapped(Baby)
            case editBirthDateTapped(Baby)
            case editGenderTapped(Baby)
            case editBloodTypeTapped(Baby)
        }
        public enum Alert: Equatable {}

        case binding(BindingAction<State>)
        case task
        case nameRowTapped
        case birthDateRowTapped
        case genderRowTapped
        case bloodTypeRowTapped
        case photoTapped
        case pickFromLibraryTapped
        case deletePhotoTapped
        case _internal(InternalAction)
        case delegate(DelegateAction)
        case alert(PresentationAction<Alert>)
    }

    @Dependency(\.babyClient) var babyClient
    @Dependency(\.storageClient) var storageClient

    private enum CancelID { case babyStream }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.pickerItem):
                guard let item = state.pickerItem else { return .none }
                state.pickerItem = nil
                state.isUploading = true
                let babyID = state.baby.id
                let oldURL = state.baby.profileImageURL
                return .run { [storageClient] send in
                    do {
                        guard let data = try await item.loadTransferable(type: Data.self) else {
                            await send(._internal(.photoActionFailed))
                            return
                        }
                        let url = try await storageClient.uploadBabyProfilePhoto(babyID, data)
                        await send(._internal(.photoUploaded(url, replacing: oldURL)))
                    } catch {
                        AppLogger.error("photo upload failed: \(error)")
                        await send(._internal(.photoActionFailed))
                    }
                }

            case .binding:
                return .none

            case .task:
                return .run { [babyClient, id = state.baby.id] send in
                    for await baby in babyClient.streamBaby(id) {
                        await send(._internal(.babyUpdated(baby)))
                    }
                }
                .cancellable(id: CancelID.babyStream, cancelInFlight: true)

            case .nameRowTapped:
                return .send(.delegate(.editNameTapped(state.baby)))

            case .birthDateRowTapped:
                return .send(.delegate(.editBirthDateTapped(state.baby)))

            case .genderRowTapped:
                return .send(.delegate(.editGenderTapped(state.baby)))

            case .bloodTypeRowTapped:
                return .send(.delegate(.editBloodTypeTapped(state.baby)))

            case .photoTapped:
                if state.baby.profileImageURL != nil {
                    state.isPhotoActionDialogPresented = true
                } else {
                    state.isPickerPresented = true
                }
                return .none

            case .pickFromLibraryTapped:
                state.isPhotoActionDialogPresented = false
                state.isPickerPresented = true
                return .none

            case .deletePhotoTapped:
                state.isPhotoActionDialogPresented = false
                guard let oldURL = state.baby.profileImageURL else { return .none }
                state.isUploading = true
                var updated = state.baby
                updated.profileImageURL = nil
                return .run { [babyClient, storageClient, updated, oldURL] send in
                    do throws(BabyError) {
                        try await babyClient.updateBaby(updated)
                        try? await storageClient.deletePhoto(oldURL)
                        await send(._internal(.photoDeleted))
                    } catch {
                        AppLogger.error("photo delete failed: \(error)")
                        await send(._internal(.photoActionFailed))
                    }
                }

            case let ._internal(.babyUpdated(baby)):
                state.baby = baby
                return .none

            case let ._internal(.photoUploaded(newURL, replacing: oldURL)):
                var updated = state.baby
                updated.profileImageURL = newURL
                return .run { [babyClient, storageClient, updated, oldURL] send in
                    do throws(BabyError) {
                        try await babyClient.updateBaby(updated)
                        if let oldURL {
                            try? await storageClient.deletePhoto(oldURL)
                        }
                        await send(._internal(.photoDeleted))
                    } catch {
                        try? await storageClient.deletePhoto(newURL)
                        AppLogger.error("baby update after upload failed: \(error)")
                        await send(._internal(.photoActionFailed))
                    }
                }

            case ._internal(.photoDeleted):
                state.isUploading = false
                return .none

            case ._internal(.photoActionFailed):
                state.isUploading = false
                state.alert = AlertState {
                    TextState("사진 처리 실패")
                } message: {
                    TextState("사진을 저장하거나 삭제하는 중 문제가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
                return .none

            case .delegate:
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
