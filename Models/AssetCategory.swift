import SwiftUI

struct AssetCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let iconName: String
    private let colorHex: String
    let itemCount: Int
    let totalValue: Double
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    init(id: UUID = UUID(),
         name: String,
         iconName: String,
         color: Color,
         itemCount: Int = 0,
         totalValue: Double = 0) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = color.toHex()
        self.itemCount = itemCount
        self.totalValue = totalValue
    }
}

// Codable 实现
extension AssetCategory {
    private enum CodingKeys: String, CodingKey {
        case id, name, iconName, colorHex, itemCount, totalValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(itemCount, forKey: .itemCount)
        try container.encode(totalValue, forKey: .totalValue)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        iconName = try container.decode(String.self, forKey: .iconName)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        itemCount = try container.decode(Int.self, forKey: .itemCount)
        totalValue = try container.decode(Double.self, forKey: .totalValue)
    }
}

// Hashable 实现
extension AssetCategory {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AssetCategory, rhs: AssetCategory) -> Bool {
        lhs.id == rhs.id
    }
}
