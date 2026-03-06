//
//  CareGiver.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation

struct Caregiver: Codable, Identifiable {
    var id: String
    var name: String?
    var email: String?
    var provider: String?
    /// 아기 문서 ID 목록. Firestore 매핑은 Caregiver+Firestore에서 처리.
    var babyIds: [String]
    var lastSelectedBabyId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case provider
        case babyIds = "babies"
        case lastSelectedBabyId
    }
}
