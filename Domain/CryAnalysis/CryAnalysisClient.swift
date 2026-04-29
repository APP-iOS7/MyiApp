import Foundation

public struct CryAnalysisClient: Sendable {
    public var analyze: @Sendable (URL) async throws(CryAnalysisError) -> CryAnalysisRecord

    public init(
        analyze: @escaping @Sendable (URL) async throws(CryAnalysisError) -> CryAnalysisRecord
    ) {
        self.analyze = analyze
    }
}
