import Foundation

public actor ImageCache {
    public static let shared = ImageCache()

    private let memoryCache: NSCache<NSURL, NSData> = {
        let cache = NSCache<NSURL, NSData>()
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()

    private init() {}

    public func data(for url: URL) async throws -> Data {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached as Data
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              !data.isEmpty
        else {
            throw ImageCacheError.invalidResponse
        }

        memoryCache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
        return data
    }
}

public enum ImageCacheError: Error {
    case invalidResponse
}
