import Foundation

/// 아기 정보를 등록하거나 수정할 수 있는 능력을 정의하는 프로토콜입니다.
public protocol BabyRegisterable: Sendable {
    /// 새로운 아기 정보를 등록합니다. 생성된 아기를 반환합니다.
    func registerBaby(_ baby: Baby) async throws(CaregiverError) -> Baby

    /// 기존 아기 정보를 업데이트합니다.
    func updateBaby(_ baby: Baby) async throws(CaregiverError)

    /// 아기 정보를 삭제합니다.
    func deleteBaby(id: String) async throws(CaregiverError)
}
