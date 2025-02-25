import Foundation
import SwiftUI

struct AssetItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var value: Double
    var purchasePrice: Double?
    var purchaseDate: Date?
    var imageName: String
    var categories: Set<AssetCategory>
    var description: String?
    let createdDate: Date
    var valueHistory: [ValueRecord]
    var reminders: [AssetReminder]
    var isCustomImage: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        purchasePrice: Double? = nil,
        purchaseDate: Date? = nil,
        imageName: String,
        categories: Set<AssetCategory>,
        description: String? = nil,
        createdDate: Date = Date(),
        valueHistory: [ValueRecord] = [],
        reminders: [AssetReminder] = [],
        isCustomImage: Bool = false
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.imageName = imageName
        self.categories = categories
        self.description = description
        self.createdDate = createdDate
        self.valueHistory = valueHistory
        self.reminders = reminders
        self.isCustomImage = isCustomImage
    }
    
    // 自定义编码键
    private enum CodingKeys: String, CodingKey {
        case id, name, value, purchasePrice, purchaseDate, imageName
        case categories, description, createdDate, valueHistory, reminders
        case isCustomImage
    }
    
    // 编码
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encode(purchasePrice, forKey: .purchasePrice)
        try container.encode(purchaseDate, forKey: .purchaseDate)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(Array(categories), forKey: .categories)
        try container.encode(description, forKey: .description)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(valueHistory, forKey: .valueHistory)
        try container.encode(reminders, forKey: .reminders)
        try container.encode(isCustomImage, forKey: .isCustomImage)
    }
    
    // 解码
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(Double.self, forKey: .value)
        purchasePrice = try container.decodeIfPresent(Double.self, forKey: .purchasePrice)
        purchaseDate = try container.decodeIfPresent(Date.self, forKey: .purchaseDate)
        imageName = try container.decode(String.self, forKey: .imageName)
        let categoriesArray = try container.decode([AssetCategory].self, forKey: .categories)
        categories = Set(categoriesArray)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        valueHistory = try container.decode([ValueRecord].self, forKey: .valueHistory)
        reminders = try container.decode([AssetReminder].self, forKey: .reminders)
        isCustomImage = try container.decode(Bool.self, forKey: .isCustomImage)
    }
    
    // 计算升值/折旧
    var valueChange: Double? {
        guard let initialValue = purchasePrice else { return nil }
        return value - initialValue
    }
    
    // 计算年化收益率
    var annualizedReturn: Double? {
        guard let purchaseDate = purchaseDate,
              let initialValue = purchasePrice,
              initialValue > 0 else { return nil }
        
        let years = Date().timeIntervalSince(purchaseDate) / (365 * 24 * 60 * 60)
        guard years > 0 else { return nil }
        
        return pow((value / initialValue), (1 / years)) - 1
    }
}
