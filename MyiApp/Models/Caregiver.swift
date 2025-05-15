//
//  CareGiver.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation

struct Caregiver: Codable, Identifiable {
    var id: String
    var babies: [Baby]
    
    init(id: String, babies: [Baby]) {
        self.id = id
        self.babies = babies
    }
}
