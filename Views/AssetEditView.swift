import SwiftUI
import PhotosUI

struct AssetEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    
    let item: AssetItem
    @State private var name: String
    @State private var value: String
    @State private var description: String
    @State private var selectedCategories: Set<AssetCategory>
    @State private var purchasePrice: String
    @State private var purchaseDate: Date
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    init(item: AssetItem) {
            self.item = item
            _name = State(initialValue: item.name)
            _value = State(initialValue: String(format: "%.2f", item.value))
            _description = State(initialValue: item.description ?? "")
            _selectedCategories = State(initialValue: item.categories)
            _purchasePrice = State(initialValue: item.purchasePrice.map { String(format: "%.2f", $0) } ?? "")
            _purchaseDate = State(initialValue: item.purchaseDate ?? Date())
        }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本信息
                BasicInfoSection(
                    name: $name,
                    value: $value,
                    description: $description
                )
                
                // 分类选择
                CategorySection(
                    selectedCategories: $selectedCategories
                )
                
                // 购买信息
                PurchaseInfoSection(
                    purchasePrice: $purchasePrice,
                    purchaseDate: $purchaseDate
                )
                
                // 图片选择
                ImageSection(
                    item: item,
                    selectedImage: $selectedImage,
                    showingImagePicker: $showingImagePicker
                )
            }
            .navigationTitle("编辑物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        updateAsset()
                        dismiss()
                    }
                    .disabled(name.isEmpty || value.isEmpty || Double(value) == nil)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func updateAsset() {
        guard let valueDouble = Double(value) else { return }
        
        var updatedItem = item
        updatedItem.name = name
        updatedItem.value = valueDouble
        updatedItem.description = description.isEmpty ? nil : description
        updatedItem.categories = selectedCategories
        updatedItem.purchasePrice = Double(purchasePrice)
        updatedItem.purchaseDate = purchaseDate
        
        if let image = selectedImage {
            // 如果是自定义图片，删除旧图片
            if item.isCustomImage {
                _ = assetManager.deleteImage(name: item.imageName)
            }
            
            let imageName = UUID().uuidString + ".jpg"
            if assetManager.saveImage(image, name: imageName) {
                updatedItem.imageName = imageName
                updatedItem.isCustomImage = true
            }
        }
        
        assetManager.updateItem(updatedItem)
    }
}

// 基本信息部分
private struct BasicInfoSection: View {
    @Binding var name: String
    @Binding var value: String
    @Binding var description: String
    
    var body: some View {
        Section(header: Text("基本信息")) {
            TextField("名称", text: $name)
            
            HStack {
                Text("¥")
                TextField("当前价值", text: $value)
                    .keyboardType(.decimalPad)
            }
            
            TextField("描述", text: $description)
        }
    }
}

// 分类选择部分
private struct CategorySection: View {
    @Binding var selectedCategories: Set<AssetCategory>
    @EnvironmentObject private var assetManager: AssetManager
    
    var body: some View {
        Section(header: Text("分类")) {
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
                .padding(.vertical, 8)
            }
        }
    }
}

// 购买信息部分
private struct PurchaseInfoSection: View {
    @Binding var purchasePrice: String
    @Binding var purchaseDate: Date
    
    var body: some View {
        Section(header: Text("购买信息")) {
            HStack {
                Text("¥")
                TextField("购买价格", text: $purchasePrice)
                    .keyboardType(.decimalPad)
            }
            
            DatePicker("购买日期", selection: $purchaseDate, displayedComponents: [.date])
        }
    }
}

// 图片选择部分
private struct ImageSection: View {
    let item: AssetItem
    @Binding var selectedImage: UIImage?
    @Binding var showingImagePicker: Bool
    @EnvironmentObject private var assetManager: AssetManager
    
    var body: some View {
        Section(header: Text("图片")) {
            HStack {
                Group {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else if item.isCustomImage,
                             let image = assetManager.loadImage(name: item.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("选择图片") {
                    showingImagePicker = true
                }
            }
        }
    }
}

#Preview {
    AssetEditView(item: AssetItem(
        name: "示例物品",
        value: 1000,
        imageName: "defaultAsset",
        categories: []
    ))
    .environmentObject(AssetManager())
}

// 分类拖放代理
struct CategoryDropDelegate: DropDelegate {
    @Binding var draggedCategory: AssetCategory?
    @Binding var categories: Set<AssetCategory>
    @Binding var hasChanges: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        hasChanges = true
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedCategory = draggedCategory else { return }
        // 实现拖拽排序逻辑
    }
    
    // 需要实现 DropDelegate 协议的其他必要方法
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return true
    }
}

// 分类标签组件
struct CategoryChip: View {
    let category: AssetCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
            Text(category.name)
            Image(systemName: "xmark")
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(category.color.opacity(0.2))
        .foregroundColor(category.color)
        .cornerRadius(20)
    }
}
