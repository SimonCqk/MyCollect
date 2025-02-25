import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject private var assetManager: AssetManager
    @State private var showingAddAsset = false
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 总资产卡片
                    AssetSummaryCard(totalValue: totalValue)
                    
                    // 最近添加
                    RecentItemsView(items: recentItems)
                    
                    // 分类统计
                    CategoryStatsView(categories: assetManager.categories, items: assetManager.items)
                }
                .padding()
            }
            .navigationTitle("资产")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        
                        Button {
                            showingAddAsset = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddAsset) {
                AddAssetView()
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
        }
    }
    
    private var totalValue: Double {
        assetManager.items.reduce(0) { $0 + $1.value }
    }
    
    private var recentItems: [AssetItem] {
        Array(assetManager.items.sorted { $0.createdDate > $1.createdDate }.prefix(5))
    }
}

// 总资产卡片组件
struct AssetSummaryCard: View {
    let totalValue: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("总资产")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("¥\(totalValue, specifier: "%.2f")")
                .font(.system(size: 36, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

// 分类统计组件 - 统一样式
struct CategoryStatsView: View {
    let categories: [AssetCategory]
    let items: [AssetItem]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类统计")
                .font(.headline)
            
            if categories.isEmpty {
                Text("暂无分类")
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(categories) { category in
                        NavigationLink(destination: CategoryDetailView(category: category)) {
                            CategoryCard(category: category, items: items)
                        }
                    }
                }
            }
        }
    }
}

// 分类卡片组件 - 统一样式
private struct CategoryCard: View {
    let category: AssetCategory
    let items: [AssetItem]
    
    private var categoryItems: [AssetItem] {
        items.filter { $0.categories.contains(category) }
    }
    
    private var totalValue: Double {
        categoryItems.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        HStack {
            // 左侧：图标
            Image(systemName: category.iconName)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(category.color)
                .clipShape(Circle())
            
            // 右侧：文字信息
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Text("¥\(totalValue, specifier: "%.0f")")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 最右侧：数量
            Text("\(categoryItems.count)")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// 最近添加组件 - 优化版
struct RecentItemsView: View {
    let items: [AssetItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近添加")
                .font(.headline)
            
            if items.isEmpty {
                Text("暂无物品")
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(items) { item in
                            NavigationLink(destination: AssetDetailView(itemId: item.id)) {
                                RecentItemCard(item: item)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// 最近添加卡片组件 - 优化版
private struct RecentItemCard: View {
    let item: AssetItem
    @EnvironmentObject private var assetManager: AssetManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 物品图片
            Group {
                if item.isCustomImage {
                    if let image = assetManager.loadImage(name: item.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                } else {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 物品信息
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15))
                
                Text("¥\(item.value, specifier: "%.0f")")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .frame(width: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(AssetManager())
} 
