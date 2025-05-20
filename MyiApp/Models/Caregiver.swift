//
//  CareGiver.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation
import FirebaseFirestore

struct Caregiver: Codable, Identifiable {
    var id: String
    var babies: [DocumentReference]
}
