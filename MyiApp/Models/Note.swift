//
//  Note.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-09.
//

import Foundation

struct Note: Codable, Identifiable {
    var id: UUID
    var createdAt: Date
    var title: String
    var content: String
}
