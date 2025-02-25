import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    
    @State private var searchText = ""
    @State private var selectedCategories: Set<AssetCategory> = []
    @State private var minPrice: String = ""
    @State private var maxPrice: String = ""
    @State private var showingFilters = false
    
    // 搜索结果
    private var filteredItems: [AssetItem] {
        var results = assetManager.items
        
        // 文本搜索
        if !searchText.isEmpty {
            results = results.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // 分类过滤
        if !selectedCategories.isEmpty {
            results = results.filter { item in
                !item.categories.isDisjoint(with: selectedCategories)
            }
        }
        
        // 价格范围过滤
        if let min = Double(minPrice) {
            results = results.filter { $0.value >= min }
        }
        if let max = Double(maxPrice) {
            results = results.filter { $0.value <= max }
        }
        
        return results
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索物品名称或描述", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // 分类选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(assetManager.categories) { category in
                            CategoryFilterChip(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // 价格范围筛选
                if showingFilters {
                    VStack(spacing: 12) {
                        HStack {
                            TextField("最低价格", text: $minPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("-")
                            
                            TextField("最高价格", text: $maxPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // 搜索结果
                if filteredItems.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("未找到相关物品")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredItems) { item in
                        NavigationLink(destination: AssetDetailView(itemId: item.id)) {
                            SearchResultRow(item: item)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showingFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
    }
}

// 搜索结果行
struct SearchResultRow: View {
    let item: AssetItem
    @EnvironmentObject private var assetManager: AssetManager
    
    var body: some View {
        HStack(spacing: 12) {
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
                
                HStack {
                    Text("¥\(item.value, specifier: "%.2f")")
                        .foregroundColor(.blue)
                    
                    if !item.categories.isEmpty {
                        Text("·")
                        Text(item.categories.first?.name ?? "")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}
