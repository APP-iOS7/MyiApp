//
//  NoteFirestoreExtension.swift
//  MyiApp
//
//  Created by Saebyeok Jang on 5/13/25.
//

import Foundation
import FirebaseFirestore

extension Note {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case category
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let idString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "Invalid UUID string"
            )
        }
        
        id = uuid
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
        category = try container.decode(NoteCategory.self, forKey: .category)
    }
}

extension Timestamp {
    var dateValue: Date {
        return Date(timeIntervalSince1970: TimeInterval(seconds) + TimeInterval(nanoseconds) / 1_000_000_000)
    }
}

extension Date {
    var timestamp: Timestamp {
        return Timestamp(date: self)
    }
}
