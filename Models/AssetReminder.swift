//
//  AssetReminder.swift
//  MyCollect
//
//  Created by 冯先生 on 2025/2/20.
//

import Foundation

struct AssetReminder: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.isCompleted = isCompleted
    }
} 
