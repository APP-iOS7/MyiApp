import Foundation

/// 보호자 정보를 등록하거나 수정할 수 있는 능력을 정의하는 프로토콜입니다.
public protocol CaregiverRegisterable: Sendable {
    /// 보호자 프로필 정보를 등록하거나 업데이트합니다.
    func updateCaregiver(_ caregiver: Caregiver) async throws(CaregiverError)
}
