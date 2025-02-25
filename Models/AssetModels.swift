import SwiftUI

// 提醒类型
enum ReminderType: String, Codable {
    case warranty    // 保修期
    case maintenance // 保养
    case insurance  // 保险
    case custom     // 自定义
}


// 示例数据
let sampleCategories = [
    AssetCategory(name: "电子设备", iconName: "laptopcomputer", color: .blue, itemCount: 8),
    AssetCategory(name: "家具", iconName: "bed.double.fill", color: .brown, itemCount: 12),
    AssetCategory(name: "宠物", iconName: "pawprint.fill", color: .orange, itemCount: 2),
    AssetCategory(name: "收藏品", iconName: "star.fill", color: .yellow, itemCount: 5)
]

let sampleRecentItems = [
    AssetItem(
        name: "MacBook Pro",
        value: 12999,
        imageName: "macbook",
        categories: Set([sampleCategories[0]]),
        description: "2023款 M2 芯片 16GB内存 512GB存储",
        createdDate: Date().addingTimeInterval(-7*24*3600)
    ),
    AssetItem(
        name: "iPhone 13",
        value: 6999,
        imageName: "iphone",
        categories: Set([sampleCategories[0]]),
        description: "128GB 午夜色",
        createdDate: Date().addingTimeInterval(-30*24*3600)
    ),
    AssetItem(
        name: "金毛犬",
        value: 3000,
        imageName: "dog",
        categories: Set([sampleCategories[2]]),
        description: "2岁大 已注射疫苗",
        createdDate: Date().addingTimeInterval(-90*24*3600)
    )
] 
