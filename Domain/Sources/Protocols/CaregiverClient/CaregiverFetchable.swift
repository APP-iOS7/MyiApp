import Foundation

/// 보호자 정보를 조회할 수 있는 능력을 정의하는 프로토콜입니다.
public protocol CaregiverFetchable: Sendable {
    /// 특정 ID의 보호자 정보를 조회합니다.
    func fetchCaregiver(id: String) async throws(CaregiverError) -> Caregiver

    /// 현재 가족 그룹에 속한 모든 보호자 목록을 조회합니다.
    func fetchFamilyCaregivers() async throws(CaregiverError) -> [Caregiver]
}
