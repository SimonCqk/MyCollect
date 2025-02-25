//
//  CategoryDetailView.swift
//  MyCollect
//
//  Created by 冯先生 on 2025/2/20.
//

import SwiftUI

struct CategoryDetailView: View {
    let category: AssetCategory
    @EnvironmentObject private var assetManager: AssetManager
    
    private var categoryItems: [AssetItem] {
        assetManager.items.filter { $0.categories.contains(category) }
    }
    
    var body: some View {
        List {
            // 分类信息
            Section {
                HStack {
                    Image(systemName: category.iconName)
                        .font(.title)
                        .foregroundColor(category.color)
                        .frame(width: 40, height: 40)
                        .background(category.color.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.headline)
                        Text("\(categoryItems.count) 个物品")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("总价值")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("¥\(categoryItems.reduce(0) { $0 + $1.value }, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("平均价值")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("¥\(categoryItems.isEmpty ? 0 : categoryItems.reduce(0) { $0 + $1.value } / Double(categoryItems.count), specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 物品列表
            Section {
                if categoryItems.isEmpty {
                    Text("暂无物品")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(categoryItems.sorted { $0.value > $1.value }) { item in
                        NavigationLink(destination: AssetDetailView(itemId: item.id)) {
                            HStack {
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
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("¥\(item.value, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            } header: {
                Text("物品列表")
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(category: AssetCategory(
            name: "电子产品",
            iconName: "iphone",
            color: .blue
        ))
        .environmentObject(AssetManager())
    }
} 
