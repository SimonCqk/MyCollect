import SwiftUI

class AssetManager: ObservableObject {
    @Published private(set) var items: [AssetItem] = []
    @Published private(set) var categories: [AssetCategory] = []
    
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // 计算属性，确保实时更新
    var totalAssets: Double {
        items.reduce(0) { $0 + $1.value }
    }
    
    var recentItems: [AssetItem] {
        Array(items.sorted { $0.createdDate > $1.createdDate }.prefix(10))
    }
    
    var categoriesWithCount: [AssetCategory] {
        categories.map { category in
            let categoryItems = items.filter { $0.categories.contains(category) }
            return AssetCategory(
                id: category.id,
                name: category.name,
                iconName: category.iconName,
                color: category.color,
                itemCount: categoryItems.count,
                totalValue: categoryItems.reduce(0) { $0 + $1.value }
            )
        }
    }
    
    init() {
        // 添加默认分类
        let electronicCategory = AssetCategory(
            name: "电子产品",
            iconName: "iphone",
            color: .blue
        )
        
        let petCategory = AssetCategory(
            name: "宠物",
            iconName: "pawprint.fill",
            color: .orange
        )
        
        categories = [electronicCategory, petCategory]
        
        // 添加默认物品
        let iphone = AssetItem(
            name: "iPhone 15",
            value: 7999,
            purchasePrice: 7999,
            purchaseDate: Date(),
            imageName: "iphone",
            categories: [electronicCategory],
            description: "iPhone 15 256GB 黑色",
            isCustomImage: false
        )
        
        let borderCollie = AssetItem(
            name: "边牧",
            value: 3000,
            purchasePrice: 3000,
            purchaseDate: Date().addingTimeInterval(-365*24*60*60), // 一年前
            imageName: "dog",
            categories: [petCategory],
            description: "可爱的边境牧羊犬",
            isCustomImage: false
        )
        
        items = [iphone, borderCollie]
        
        // 保存初始数据
        saveData()
    }
    
    // CRUD 操作
    func addItem(_ item: AssetItem) {
        items.append(item)
        saveData()
        objectWillChange.send() // 显式触发更新
    }
    
    func updateItem(_ updatedItem: AssetItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveData()
            objectWillChange.send() // 显式触发更新
        }
    }
    
    func deleteItem(_ item: AssetItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if item.isCustomImage {
                deleteImage(name: item.imageName)
            }
            items.remove(at: index)
            saveData()
            objectWillChange.send() // 显式触发更新
        }
    }
    
    func getItem(withId id: UUID) -> AssetItem? {
        items.first(where: { $0.id == id })
    }
    
    // 数据持久化
    private func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            try data.write(to: documentsPath.appendingPathComponent("items.json"))
            
            let categoriesData = try encoder.encode(categories)
            try categoriesData.write(to: documentsPath.appendingPathComponent("categories.json"))
        } catch {
            print("保存数据失败：\(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        do {
            let itemsData = try Data(contentsOf: documentsPath.appendingPathComponent("items.json"))
            items = try JSONDecoder().decode([AssetItem].self, from: itemsData)
            
            let categoriesData = try Data(contentsOf: documentsPath.appendingPathComponent("categories.json"))
            categories = try JSONDecoder().decode([AssetCategory].self, from: categoriesData)
        } catch {
            print("加载数据失败：\(error.localizedDescription)")
            // 如果是首次运行，加载默认分类
            if categories.isEmpty {
                loadDefaultCategories()
            }
        }
    }
    
    // 图片处理
    func saveImage(_ image: UIImage, name: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return false }
        let imageUrl = documentsPath.appendingPathComponent(name)
        
        do {
            try data.write(to: imageUrl)
            return true
        } catch {
            print("保存图片失败：\(error.localizedDescription)")
            return false
        }
    }
    
    func loadImage(name: String) -> UIImage? {
        let imageUrl = documentsPath.appendingPathComponent(name)
        return UIImage(contentsOfFile: imageUrl.path)
    }
    
    func deleteImage(name: String) -> Bool {
        let imageUrl = documentsPath.appendingPathComponent(name)
        
        do {
            try fileManager.removeItem(at: imageUrl)
            return true
        } catch {
            print("删除图片失败：\(error.localizedDescription)")
            return false
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func loadDefaultCategories() {
        categories = [
            AssetCategory(name: "电子产品", iconName: "iphone", color: .blue),
            AssetCategory(name: "家具", iconName: "bed.double", color: .brown),
            AssetCategory(name: "服饰", iconName: "tshirt", color: .purple),
            AssetCategory(name: "珠宝", iconName: "sparkles", color: .yellow),
            AssetCategory(name: "收藏品", iconName: "star", color: .orange),
            AssetCategory(name: "其他", iconName: "archivebox", color: .gray)
        ]
        saveData()
    }
    
    // 添加分类
    func addCategory(_ category: AssetCategory) {
        categories.append(category)
        saveData()
    }
    
    // 删除分类
    func deleteCategory(_ category: AssetCategory) {
        // 先更新所有包含此分类的物品
        for var item in items where item.categories.contains(category) {
            item.categories.remove(category)
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            }
        }
        
        // 然后删除分类
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories.remove(at: index)
        }
        
        saveData()
    }
}
