import Foundation

public enum APIConfig {

    /// Backend base URL. Change here for staging / local dev.
    public static let baseURL: URL = URL(string: "https://myiapp.duckdns.org")!

    /// Public S3-compatible endpoint (MinIO). The backend issues presigned URLs
    /// pointing here, and the iOS client constructs canonical write URLs against
    /// this host; the backend extracts just the object key on store.
    public static let storageBaseURL: URL = URL(string: "https://myiapp-s3.duckdns.org")!

    public static let storageBucket: String = "myiapp-uploads"

    /// JSONDecoder that handles ISO8601 dates with or without fractional seconds.
    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = ISO8601.fractional.date(from: raw) { return date }
            if let date = ISO8601.plain.date(from: raw) { return date }
            // Try plain yyyy-MM-dd (Baby.birthDate is a LocalDate on backend).
            if let date = DateOnly.formatter.date(from: raw) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format: \(raw)"
            )
        }
        return decoder
    }()

    /// JSONEncoder that emits ISO8601 with fractional seconds for instants.
    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(ISO8601.fractional.string(from: date))
        }
        return encoder
    }()
}

enum ISO8601 {
    static let fractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    static let plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}

enum DateOnly {
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
