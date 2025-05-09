//
//  BabyInfoModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Baby: Codable, Identifiable {
    var id: UUID
    var name: String
    var birthDate: Date
    var gender: Gender
    var height: Double
    var weight: Double
    var bloodType: BloodType
    var photoURL: String?
    
    var careGivers: [CareGiver]
    var records: [Record]
    var voiceRecords: [VoiceRecord]
    var note: [Note]
}

enum BloodType: String, Codable {
    case A, B, O, AB
}

enum Gender: Int, Codable {
    case male = 1
    case female = 2
}
