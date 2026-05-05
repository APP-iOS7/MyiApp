import ComposableArchitecture
import Domain
import Foundation
import Shared

extension StorageClient: @retroactive TestDependencyKey {}
extension StorageClient: @retroactive DependencyKey {
    public static let liveValue = Self(
        uploadDiaryPhoto: { @Sendable babyID, _, data async throws(Domain.StorageError) -> URL in
            try await uploadImageData(babyID: babyID, data: data, kind: .noteImage, label: "uploadDiaryPhoto")
        },
        uploadDiaryPhotoFile: { @Sendable babyID, _, fileURL async throws(Domain.StorageError) -> URL in
            do {
                let data = try Data(contentsOf: fileURL)
                let url = try await uploadImageData(
                    babyID: babyID,
                    data: data,
                    kind: .noteImage,
                    label: "uploadDiaryPhotoFile"
                )
                await URLDataCache.shared.store(data, for: url)
                return url
            } catch let storage as Domain.StorageError {
                throw storage
            } catch {
                AppLogger.error("uploadDiaryPhotoFile read failed: \(error)")
                throw .unexpected
            }
        },
        uploadBabyProfilePhoto: { @Sendable babyID, data async throws(Domain.StorageError) -> URL in
            try await uploadImageData(babyID: babyID, data: data, kind: .profile, label: "uploadBabyProfilePhoto")
        },
        deletePhoto: { @Sendable downloadURL async throws(Domain.StorageError) in
            // Backend doesn't expose a direct object delete endpoint yet.
            // Photos referenced by Note.imageURLs / Baby.profileImageURL are
            // dereferenced via PATCH; orphaned objects can be GC'd server-side later.
            AppLogger.info("deletePhoto noop url=\(downloadURL)")
        }
    )
}

extension DependencyValues {
    public var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}

// MARK: - Upload core

private func uploadImageData(
    babyID: UUID,
    data: Data,
    kind: UploadKindDTO,
    label: String
) async throws(Domain.StorageError) -> URL {
    guard AuthState.shared.snapshot() != nil else {
        AppLogger.error("\(label) unauthorized babyID=\(babyID)")
        throw .unauthorized
    }
    let contentType = inferImageContentType(data: data)
    AppLogger.info("\(label) start babyID=\(babyID) bytes=\(data.count) contentType=\(contentType)")

    do {
        let presigned: PresignedUploadResponseDTO = try await APIClient.shared.postJSON(
            "/babies/\(babyID.uuidString)/uploads",
            body: PresignedUploadRequestDTO(kind: kind, contentType: contentType)
        )
        try await put(data: data, to: presigned.uploadUrl, contentType: contentType)

        let canonical = APIConfig.storageBaseURL
            .appendingPathComponent(APIConfig.storageBucket)
            .appendingPathComponent(presigned.key)
        await URLDataCache.shared.store(data, for: canonical)
        AppLogger.info("\(label) done key=\(presigned.key)")
        return canonical
    } catch let api as APIError {
        AppLogger.error("\(label) failed: \(api)")
        throw mapStorageError(api)
    } catch {
        AppLogger.error("\(label) unexpected: \(error)")
        throw .unexpected
    }
}

private func put(data: Data, to urlString: String, contentType: String) async throws {
    guard let url = URL(string: urlString) else {
        throw APIError.unexpected("bad presigned url")
    }
    var req = URLRequest(url: url)
    req.httpMethod = "PUT"
    req.setValue(contentType, forHTTPHeaderField: "Content-Type")
    req.httpBody = data
    let (_, response) = try await URLSession.shared.upload(for: req, from: data)
    guard let http = response as? HTTPURLResponse else {
        throw APIError.network("upload non-http")
    }
    guard (200..<300).contains(http.statusCode) else {
        throw APIError.unexpected("upload status \(http.statusCode)")
    }
}

private func mapStorageError(_ error: APIError) -> Domain.StorageError {
    switch error {
    case .unauthorized: return .unauthorized
    case .forbidden:    return .unauthorized
    case .notFound:     return .objectNotFound
    default:            return .unexpected
    }
}

// MARK: - Content type inference (kept from previous implementation)

private func inferImageContentType(data: Data) -> String {
    let prefix = Array(data.prefix(12))
    if prefix.count >= 3, prefix[0] == 0xFF, prefix[1] == 0xD8, prefix[2] == 0xFF {
        return "image/jpeg"
    }
    if prefix.count >= 8,
       prefix[0] == 0x89, prefix[1] == 0x50, prefix[2] == 0x4E, prefix[3] == 0x47,
       prefix[4] == 0x0D, prefix[5] == 0x0A, prefix[6] == 0x1A, prefix[7] == 0x0A
    {
        return "image/png"
    }
    if prefix.count >= 12,
       prefix[4] == 0x66, prefix[5] == 0x74, prefix[6] == 0x79, prefix[7] == 0x70
    {
        let brand = Array(prefix[8 ..< 12])
        let heicBrands: [[UInt8]] = [
            [0x68, 0x65, 0x69, 0x63],
            [0x68, 0x65, 0x69, 0x78],
            [0x68, 0x65, 0x76, 0x63],
            [0x68, 0x65, 0x76, 0x78],
            [0x6D, 0x69, 0x66, 0x31],
            [0x6D, 0x73, 0x66, 0x31]
        ]
        if heicBrands.contains(brand) { return "image/heic" }
    }
    if prefix.count >= 12,
       prefix[0] == 0x52, prefix[1] == 0x49, prefix[2] == 0x46, prefix[3] == 0x46,
       prefix[8] == 0x57, prefix[9] == 0x45, prefix[10] == 0x42, prefix[11] == 0x50
    {
        return "image/webp"
    }
    // Backend whitelist allows: jpeg/png/heic/webp. Default to jpeg as safe fallback.
    return "image/jpeg"
}
