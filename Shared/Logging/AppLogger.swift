import Foundation
import OSLog

public enum AppLogger {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "kr.co.codegrove.MyI",
        category: "App"
    )

    public static func debug(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let body = message()
        logger
            .debug(
                "\(prefix(file: file, function: function, line: line), privacy: .public) — \(body, privacy: .public)"
            )
    }

    public static func info(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let body = message()
        logger
            .info("\(prefix(file: file, function: function, line: line), privacy: .public) — \(body, privacy: .public)")
    }

    public static func notice(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let body = message()
        logger
            .notice(
                "\(prefix(file: file, function: function, line: line), privacy: .public) — \(body, privacy: .public)"
            )
    }

    public static func error(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let body = message()
        logger
            .error(
                "\(prefix(file: file, function: function, line: line), privacy: .public) — \(body, privacy: .public)"
            )
    }

    public static func fault(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let body = message()
        logger
            .fault(
                "\(prefix(file: file, function: function, line: line), privacy: .public) — \(body, privacy: .public)"
            )
    }

    private static func prefix(file: String, function: String, line: Int) -> String {
        "\(file):\(line) \(function)"
    }
}
