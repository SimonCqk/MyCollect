import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var assetManager: AssetManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 总资产卡片
                    AssetSummaryView(totalAssets: assetManager.totalAssets)
                    
                    // 物品持有时间统计
                    HoldingTimeSection(items: assetManager.items)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6))
            .navigationTitle("统计")
        }
        .id(assetManager.items.count)
    }
}

// 总资产视图
private struct AssetSummaryView: View {
    let totalAssets: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("总资产")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("¥\(totalAssets, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

// 持有时间区域
private struct HoldingTimeSection: View {
    let items: [AssetItem]
    
    // 计算物品的持有天数
    private func daysFromPurchase(_ date: Date?) -> Int {
        guard let purchaseDate = date else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: purchaseDate, to: Date())
        return components.day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("持有时间")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(items.sorted(by: {
                ($0.purchaseDate ?? $0.createdDate) > ($1.purchaseDate ?? $1.createdDate)
            })) { item in
                ItemHoldingTimeRow(
                    item: item,
                    daysFromCreation: daysFromPurchase(item.purchaseDate)
                )
            }
            .padding(.horizontal)
        }
    }
}

// 辅助扩展
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

extension Date {
    var monthAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: self)
    }
}

// 物品持有时间行
private struct ItemHoldingTimeRow: View {
    let item: AssetItem
    let daysFromCreation: Int
    @EnvironmentObject private var assetManager: AssetManager
    
    // 提取图片加载逻辑到计算属性
    private var itemImage: some View {
        if item.isCustomImage {
            if let image = assetManager.loadImage(name: item.imageName) {
                return Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                return Image("default-asset") // 使用通用默认图片
                    .resizable()
                    .scaledToFit()
            }
        } else {
            return Image(item.imageName)
                .resizable()
                .scaledToFit()
        }
    }
    
    var body: some View {
        HStack {
            // 物品图片
            itemImage
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text("¥\(item.value, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(daysFromCreation)天")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
} 
