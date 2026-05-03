import CryptoKit
import Foundation

public actor ImageCache {
    public static let shared = ImageCache()

    private let memoryCache: NSCache<NSURL, NSData> = {
        let cache = NSCache<NSURL, NSData>()
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()

    private let diskDirectory: URL

    private init() {
        let baseURL = URL.cachesDirectory.appending(path: "ImageCache")
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        self.diskDirectory = baseURL
    }

    public func data(for url: URL) async throws -> Data {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached as Data
        }

        if let diskData = readFromDisk(for: url) {
            memoryCache.setObject(diskData as NSData, forKey: url as NSURL, cost: diskData.count)
            return diskData
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              !data.isEmpty
        else {
            throw ImageCacheError.invalidResponse
        }

        memoryCache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
        writeToDisk(data, for: url)
        return data
    }

    private func readFromDisk(for url: URL) -> Data? {
        try? Data(contentsOf: diskFileURL(for: url))
    }

    private func writeToDisk(_ data: Data, for url: URL) {
        try? data.write(to: diskFileURL(for: url), options: .atomic)
    }

    private func diskFileURL(for url: URL) -> URL {
        diskDirectory.appending(path: cacheKey(for: url))
    }

    private func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

public enum ImageCacheError: Error {
    case invalidResponse
}
