import Foundation

public struct CryAnalysisClient: Sendable {
    public var levels: @Sendable () -> AsyncStream<[Float]>
    public var record: @Sendable (UUID) async throws(CryAnalysisError) -> CryAnalysisRecord

    public init(
        levels: @escaping @Sendable () -> AsyncStream<[Float]>,
        record: @escaping @Sendable (UUID) async throws(CryAnalysisError) -> CryAnalysisRecord
    ) {
        self.levels = levels
        self.record = record
    }
}
