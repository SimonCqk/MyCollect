import SwiftUI

struct AssetDetailView: View {
    let itemId: UUID
    @EnvironmentObject private var assetManager: AssetManager
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var item: AssetItem? {
        assetManager.getItem(withId: itemId)
    }
    
    var body: some View {
        ScrollView {
            if let currentItem = item {
                VStack(spacing: 20) {
                    // 图片部分
                    AssetImageView(item: currentItem)
                    
                    // 基本信息
                    AssetBasicInfoView(item: currentItem)
                    
                    // 分类标签
                    CategoryTagsView(categories: currentItem.categories)
                    
                    // 购买信息
                    if currentItem.purchasePrice != nil || currentItem.purchaseDate != nil {
                        PurchaseInfoView(item: currentItem)
                    }
                    
                    // 描述信息
                    if let description = currentItem.description {
                        DescriptionView(text: description)
                    }
                }
                .padding()
            } else {
                Text("物品不存在")
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if item != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("编辑") {
                            showingEditSheet = true
                        }
                        
                        Button("删除", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let currentItem = item {
                AssetEditView(item: currentItem)
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteItem()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销")
        }
    }
    
    private func deleteItem() {
        if let currentItem = item {
            assetManager.deleteItem(currentItem)
        }
    }
}

// 图片视图组件
private struct AssetImageView: View {
    let item: AssetItem
    @EnvironmentObject private var assetManager: AssetManager
    
    var body: some View {
        Group {
            if item.isCustomImage {
                if let image = assetManager.loadImage(name: item.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            } else {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxHeight: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// 基本信息视图组件
private struct AssetBasicInfoView: View {
    let item: AssetItem
    
    var body: some View {
        VStack(spacing: 8) {
            Text(item.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text("¥\(item.value, specifier: "%.2f")")
                .font(.title2)
                .foregroundColor(.blue)
        }
    }
}

// 分类标签视图组件
private struct CategoryTagsView: View {
    let categories: Set<AssetCategory>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(categories)) { category in
                    HStack {
                        Image(systemName: category.iconName)
                        Text(category.name)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(category.color.opacity(0.1))
                    .foregroundColor(category.color)
                    .clipShape(Capsule())
                }
            }
        }
    }
}

// 购买信息视图组件
private struct PurchaseInfoView: View {
    let item: AssetItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("购买信息")
                .font(.headline)
            
            if let price = item.purchasePrice {
                HStack {
                    Text("购买价格")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("¥\(price, specifier: "%.2f")")
                }
            }
            
            if let date = item.purchaseDate {
                HStack {
                    Text("购买日期")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(date.formatted(date: .numeric, time: .omitted))
                }
            }
            
            if let change = item.valueChange {
                HStack {
                    Text("价值变化")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(change >= 0 ? "+" : "")
                    + Text("¥\(change, specifier: "%.2f")")
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }
            
            if let return_ = item.annualizedReturn {
                HStack {
                    Text("年化收益")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(return_ >= 0 ? "+" : "")
                    + Text("\(return_ * 100, specifier: "%.1f")%")
                        .foregroundColor(return_ >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

// 描述信息视图组件
private struct DescriptionView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("描述")
                .font(.headline)
            
            Text(text)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    NavigationView {
        AssetDetailView(itemId: UUID())
            .environmentObject(AssetManager())
    }
} 
