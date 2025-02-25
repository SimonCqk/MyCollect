import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject private var assetManager: AssetManager
    @State private var showingAddCategory = false
    
    var body: some View {
        List {
            ForEach(assetManager.categories) { category in
                NavigationLink(destination: CategoryDetailView(category: category)) {
                    CategoryRow(category: category)
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .navigationTitle("分类管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = assetManager.categories[index]
            assetManager.deleteCategory(category)
        }
    }
}

struct CategoryRow: View {
    let category: AssetCategory
    @EnvironmentObject private var assetManager: AssetManager
    
    private var categoryItems: [AssetItem] {
        assetManager.items.filter { $0.categories.contains(category) }
    }
    
    var body: some View {
        HStack {
            Image(systemName: category.iconName)
                .foregroundColor(category.color)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                
                Text("\(categoryItems.count) 个物品 · ¥\(categoryItems.reduce(0) { $0 + $1.value }, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        CategoryListView()
            .environmentObject(AssetManager())
    }
} 
