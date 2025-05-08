//
//  BabyInfoModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import Foundation
import FirebaseFirestore

struct BabyInfoModel: Codable, Identifiable {
    var id: UUID
    var nickname: String
    var name: String
    var birthDate: Date
    
}

