import ComposableArchitecture
import Domain
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseStorage
import Foundation

extension StorageClient: @retroactive TestDependencyKey {}
extension StorageClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        uploadDiaryPhoto: { @Sendable babyID, noteID, data async throws(Domain.StorageError) -> URL in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            let photoID = UUID()
            let path = diaryPhotoPath(babyID: babyID, noteID: noteID, photoID: photoID)
            let reference = Storage.storage().reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = inferImageContentType(data: data)
            do {
                _ = try await reference.putDataAsync(data, metadata: metadata)
                return try await reference.downloadURL()
            } catch {
                throw mapStorageError(error)
            }
        },
        uploadDiaryPhotoFile: { @Sendable babyID, noteID, fileURL async throws(Domain.StorageError) -> URL in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            let photoID = UUID()
            let path = diaryPhotoPath(babyID: babyID, noteID: noteID, photoID: photoID)
            let reference = Storage.storage().reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = inferImageContentTypeFromFile(at: fileURL)
            do {
                _ = try await reference.putFileAsync(from: fileURL, metadata: metadata)
                return try await reference.downloadURL()
            } catch {
                throw mapStorageError(error)
            }
        },
        deleteDiaryPhoto: { @Sendable downloadURL async throws(Domain.StorageError) -> Void in
            guard Auth.auth().currentUser?.uid != nil else {
                throw .unauthorized
            }
            do {
                let reference = Storage.storage().reference(forURL: downloadURL.absoluteString)
                try await reference.delete()
            } catch {
                throw mapStorageError(error)
            }
        }
    )
}

public extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}

private func diaryPhotoPath(babyID: UUID, noteID: UUID, photoID: UUID) -> String {
    "babies/\(babyID.uuidString)/notes/\(noteID.uuidString)/photos/\(photoID.uuidString)"
}

private func mapStorageError(_ error: Error) -> Domain.StorageError {
    let nsError = error as NSError
    guard nsError.domain == StorageErrorDomain,
          let code = StorageErrorCode(rawValue: nsError.code) else {
        return .unexpected
    }
    switch code {
    case .unauthorized, .unauthenticated:
        return .unauthorized
    case .quotaExceeded:
        return .quotaExceeded
    case .objectNotFound:
        return .objectNotFound
    default:
        return .unexpected
    }
}

private func inferImageContentTypeFromFile(at url: URL) -> String {
    guard let handle = try? FileHandle(forReadingFrom: url) else {
        return "application/octet-stream"
    }
    defer { try? handle.close() }
    let prefix = (try? handle.read(upToCount: 12)) ?? Data()
    return inferImageContentType(data: prefix)
}

private func inferImageContentType(data: Data) -> String {
    let prefix = Array(data.prefix(12))
    if prefix.count >= 3, prefix[0] == 0xFF, prefix[1] == 0xD8, prefix[2] == 0xFF {
        return "image/jpeg"
    }
    if prefix.count >= 8,
       prefix[0] == 0x89, prefix[1] == 0x50, prefix[2] == 0x4E, prefix[3] == 0x47,
       prefix[4] == 0x0D, prefix[5] == 0x0A, prefix[6] == 0x1A, prefix[7] == 0x0A {
        return "image/png"
    }
    if prefix.count >= 12,
       prefix[4] == 0x66, prefix[5] == 0x74, prefix[6] == 0x79, prefix[7] == 0x70 {
        let brand = Array(prefix[8 ..< 12])
        let heicBrands: [[UInt8]] = [
            [0x68, 0x65, 0x69, 0x63], // heic
            [0x68, 0x65, 0x69, 0x78], // heix
            [0x68, 0x65, 0x76, 0x63], // hevc
            [0x68, 0x65, 0x76, 0x78], // hevx
            [0x6D, 0x69, 0x66, 0x31], // mif1
            [0x6D, 0x73, 0x66, 0x31] // msf1
        ]
        if heicBrands.contains(brand) {
            return "image/heic"
        }
    }
    if prefix.count >= 6,
       prefix[0] == 0x47, prefix[1] == 0x49, prefix[2] == 0x46, prefix[3] == 0x38 {
        return "image/gif"
    }
    if prefix.count >= 12,
       prefix[0] == 0x52, prefix[1] == 0x49, prefix[2] == 0x46, prefix[3] == 0x46,
       prefix[8] == 0x57, prefix[9] == 0x45, prefix[10] == 0x42, prefix[11] == 0x50 {
        return "image/webp"
    }
    return "application/octet-stream"
}
