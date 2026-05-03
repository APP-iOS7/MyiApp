import Foundation

public final class ImageMemoryCache: @unchecked Sendable {
    public static let shared = ImageMemoryCache()

    private let cache: NSCache<NSURL, NSData> = {
        let cache = NSCache<NSURL, NSData>()
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()

    private init() {}

    public func data(for url: URL) -> Data? {
        cache.object(forKey: url as NSURL) as Data?
    }

    public func store(_ data: Data, for url: URL) {
        cache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
    }
}
