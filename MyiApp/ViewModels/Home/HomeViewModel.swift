//
//  HomeViewModel.swift
//  MyiApp
//
//  Created by 최범수 on 2025-05-08.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var selectedBaby: Baby?
    @Published var records: [Record] = Record.mockRecords
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: GridItemCategory?
    @Published var isFlipped = false
//    private let db = DatabaseService.shared
    
    func loadBabyInfo() { }
    
    func loadRecords(for date: Date) { }
    
    func addRecord(_ record: Record) { }
    
    func deleteRecord(_ record: Record) { }
}
