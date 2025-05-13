//
//  VoiceRecord.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation

struct VoiceRecord: Codable, Identifiable {
    var id: UUID
    var createdAt: Date
    var recordReference: String
    var firstLabel: CryEmotion
    var firstLabelConfidence: Double
    var secondLabel: CryEmotion
    var secondLabelConfidence: Double
}

enum CryEmotion: String, CaseIterable, Codable {
    case bellyPain = "belly_pain"
    case burping
    case coldHot = "cold_hot"
    case discomfort
    case hungry
    case lonely
    case scared
    case tired
    case unknown
}
