import CryptoKit
import Foundation

public actor ImageCache {
    public static let shared = ImageCache()

    nonisolated let diskDirectory: URL = {
        let url = URL.cachesDirectory.appending(path: "ImageCache")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    private let diskSizeLimit: Int = 500 * 1024 * 1024
    private let diskSizeTarget: Int = 350 * 1024 * 1024

    private var inflightFetches: [URL: Task<Data, Error>] = [:]

    private init() {}

    @MainActor
    public func cachedDataSync(for url: URL) -> Data? {
        if let cached = ImageMemoryCache.shared.data(for: url) {
            return cached
        }
        return try? Data(contentsOf: diskFileURL(for: url))
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

        let task = Task { try await self.fetchAndStore(url: url) }
        inflightFetches[url] = task
        defer { inflightFetches[url] = nil }
        return try await task.value
    }

    private func fetchAndStore(url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299) ~= httpResponse.statusCode,
              !data.isEmpty
        else { throw ImageCacheError.invalidResponse }

        store(data, for: url)
        return data
    }

    public func store(_ data: Data, for url: URL) {
        ImageMemoryCache.shared.store(data, for: url)
        writeToDisk(data, for: url)
    }
}

// MARK: - Disk IO

extension ImageCache {
    func readFromDisk(for url: URL) -> Data? {
        try? Data(contentsOf: diskFileURL(for: url))
    }

    func writeToDisk(_ data: Data, for url: URL) {
        try? data.write(to: diskFileURL(for: url), options: .atomic)
    }

    nonisolated func diskFileURL(for url: URL) -> URL {
        diskDirectory.appending(path: cacheKey(for: url))
    }

    nonisolated func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Disk Trim

extension ImageCache {
    public func trimDisk() {
        let entries = collectDiskEntries()
        let totalSize = entries.reduce(0) { $0 + $1.size }
        guard totalSize > diskSizeLimit else { return }

        evictOldest(from: entries, until: totalSize - diskSizeTarget)
    }

    private func collectDiskEntries() -> [DiskEntry] {
        let resourceKeys: Set<URLResourceKey> = [.fileSizeKey, .contentAccessDateKey]
        guard let enumerator = FileManager.default.enumerator(
            at: diskDirectory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
        )
        else {
            return []
        }

        var entries: [DiskEntry] = []
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let size = values.fileSize,
                  let accessed = values.contentAccessDate
            else { continue }

            entries.append(DiskEntry(url: fileURL, size: size, accessed: accessed))
        }
        return entries
    }

    private func evictOldest(from entries: [DiskEntry], until bytesToDelete: Int) {
        let oldestFirst = entries.sorted { $0.accessed < $1.accessed }
        var remaining = bytesToDelete
        for entry in oldestFirst {
            if remaining <= 0 { break }
            try? FileManager.default.removeItem(at: entry.url)
            remaining -= entry.size
        }
    }
}
