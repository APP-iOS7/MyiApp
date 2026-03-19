import Foundation

/// 보호자 간의 연결(가족 초대/수락 등)을 관리하는 능력을 정의하는 프로토콜입니다.
public protocol CaregiverConnectable: Sendable {
    /// 다른 보호자를 가족으로 초대합니다.
    func inviteCaregiver(email: String) async throws(CaregiverError)

    /// 가족 초대 요청을 수락하거나 거절합니다.
    func respondToInvitation(invitationID: String, accept: Bool) async throws(CaregiverError)

    /// 가족 연결을 해제합니다.
    func disconnectCaregiver(id: String) async throws(CaregiverError)
}
