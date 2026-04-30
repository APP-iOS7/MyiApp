import ComposableArchitecture
import Domain
import Foundation

extension StorageClient {
    public static let previewValue = Self(
        uploadDiaryPhoto: { _, _, _ in
            URL(string: "https://picsum.photos/200") ?? URL(filePath: "/")
        },
        uploadDiaryPhotoFile: { _, _, _ in
            URL(string: "https://picsum.photos/200") ?? URL(filePath: "/")
        },
        deleteDiaryPhoto: { _ in }
    )
}
