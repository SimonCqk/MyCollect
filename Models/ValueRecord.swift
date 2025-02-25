//
//  ValueRecord.swift
//  MyCollect
//
//  Created by 冯先生 on 2025/2/20.
//
import Foundation

struct ValueRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let value: Double
    
    init(id: UUID = UUID(), date: Date = Date(), value: Double) {
        self.id = id
        self.date = date
        self.value = value
    }
} 
