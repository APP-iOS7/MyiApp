import Foundation

public struct StorageClient: Sendable {
    public var uploadDiaryPhoto: @Sendable (UUID, UUID, Data) async throws(StorageError) -> URL
    public var uploadDiaryPhotoFile: @Sendable (UUID, UUID, URL) async throws(StorageError) -> URL
    public var deletePhoto: @Sendable (URL) async throws(StorageError) -> Void

    public init(
        uploadDiaryPhoto: @escaping @Sendable (UUID, UUID, Data) async throws(StorageError) -> URL,
        uploadDiaryPhotoFile: @escaping @Sendable (UUID, UUID, URL) async throws(StorageError) -> URL,
        deletePhoto: @escaping @Sendable (URL) async throws(StorageError) -> Void
    ) {
        self.uploadDiaryPhoto = uploadDiaryPhoto
        self.uploadDiaryPhotoFile = uploadDiaryPhotoFile
        self.deletePhoto = deletePhoto
    }
}
