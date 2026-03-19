import Foundation

/// 아기 정보를 조회할 수 있는 능력을 정의하는 프로토콜입니다.
public protocol BabyFetchable: Sendable {
    /// 현재 보호자에게 연결된 모든 아기 목록을 조회합니다.
    func fetchBabies() async throws(CaregiverError) -> [Baby]

    /// 특정 ID의 아기 정보를 조회합니다.
    func fetchBaby(id: String) async throws(CaregiverError) -> Baby
}
