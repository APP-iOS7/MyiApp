//
//  BabyInfoModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-07.
//

import Foundation
import FirebaseFirestore

struct Baby: Codable, Identifiable {
    var id: UUID
    var name: String
    var birthDate: Date
    var gender: Gender
    var height: Double
    var weight: Double
    var bloodType: BloodType
    var photoURL: String?
    
    var caregivers: [DocumentReference]
    
    init(name: String, birthDate: Date, gender: Gender, height: Double, weight: Double, bloodType: BloodType) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.photoURL = nil
        self.caregivers = []
    }
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case birthDate = "birth_date"
            case gender
            case height
            case weight
            case bloodType = "blood_type"
            case photoURL = "photo_url"
            case caregivers
        }
}

enum BloodType: String, Codable {
    case A, B, O, AB
}

enum Gender: Int, Codable {
    case male = 1
    case female = 2
}
