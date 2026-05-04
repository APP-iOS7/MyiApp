import CryptoKit
import Foundation

public actor ImageCache {
    public static let shared = ImageCache()

    nonisolated private let diskDirectory: URL
    private let diskSizeLimit: Int = 500 * 1024 * 1024
    private let diskSizeTarget: Int = 350 * 1024 * 1024

    private var inflightFetches: [URL: Task<Data, Error>] = [:]

    private init() {
        let baseURL = URL.cachesDirectory.appending(path: "ImageCache")
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        self.diskDirectory = baseURL
    }

    public func data(for url: URL) async throws -> Data {
        if let cached = ImageMemoryCache.shared.data(for: url) {
            return cached
        }

        if let diskData = readFromDisk(for: url) {
            ImageMemoryCache.shared.store(diskData, for: url)
            return diskData
        }

        if let existing = inflightFetches[url] {
            return try await existing.value
        }

        let task = Task { [weak self] in
            try await ImageCache.fetchAndStore(url: url, cache: self)
        }
        inflightFetches[url] = task
        defer { inflightFetches[url] = nil }
        return try await task.value
    }

    private static func fetchAndStore(url: URL, cache: ImageCache?) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              !data.isEmpty
        else {
            throw ImageCacheError.invalidResponse
        }

        await cache?.store(data, for: url)
        return data
    }

    public func store(_ data: Data, for url: URL) {
        ImageMemoryCache.shared.store(data, for: url)
        writeToDisk(data, for: url)
    }

    private func readFromDisk(for url: URL) -> Data? {
        try? Data(contentsOf: diskFileURL(for: url))
    }

    private func writeToDisk(_ data: Data, for url: URL) {
        try? data.write(to: diskFileURL(for: url), options: .atomic)
        enforceDiskLimit()
    }

    private func enforceDiskLimit() {
        let resourceKeys: Set<URLResourceKey> = [.fileSizeKey, .contentAccessDateKey]
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: diskDirectory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
        ) else {
            return
        }

        var entries: [(url: URL, size: Int, accessed: Date)] = []
        var totalSize = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let size = values.fileSize,
                  let accessed = values.contentAccessDate
            else { continue }
            entries.append((fileURL, size, accessed))
            totalSize += size
        }

        guard totalSize > diskSizeLimit else { return }

        entries.sort { $0.accessed < $1.accessed }
        var bytesToDelete = totalSize - diskSizeTarget
        for entry in entries {
            if bytesToDelete <= 0 { break }
            try? fileManager.removeItem(at: entry.url)
            bytesToDelete -= entry.size
        }
    }

    nonisolated private func diskFileURL(for url: URL) -> URL {
        diskDirectory.appending(path: cacheKey(for: url))
    }

    nonisolated private func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    @MainActor
    public func cachedDataSync(for url: URL) -> Data? {
        if let cached = ImageMemoryCache.shared.data(for: url) {
            return cached
        }
        return try? Data(contentsOf: diskFileURL(for: url))
    }
}

public enum ImageCacheError: Error {
    case invalidResponse
}
