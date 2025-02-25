import SwiftUI
import PhotosUI

struct AddAssetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    
    @State private var name = ""
    @State private var value = ""
    @State private var description = ""
    @State private var selectedCategories: Set<AssetCategory> = []
    @State private var purchasePrice = ""
    @State private var purchaseDate = Date()
    @State private var selectedImage: UIImage?
    
    // 定义 sheet 类型
    private enum ActiveSheet: Identifiable {
        case imagePicker
        case addCategory
        
        var id: Int {
            hashValue
        }
    }
    
    // 统一的 sheet 状态
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        NavigationView {
            Form {
                // 基本信息
                Section(header: Text("基本信息")) {
                    TextField("名称", text: $name)
                    
                    HStack {
                        Text("¥")
                        TextField("当前价值", text: $value)
                            .keyboardType(.decimalPad)
                    }
                    
                    TextField("描述", text: $description)
                }
                
                // 分类选择
                Section("分类") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: {
                                activeSheet = .addCategory
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("新增")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            ForEach(assetManager.categories) { category in
                                CategorySelectButton(
                                    category: category,
                                    isSelected: selectedCategories.contains(category),
                                    action: {
                                        toggleCategory(category)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                
                // 购买信息
                Section(header: Text("购买信息")) {
                    HStack {
                        Text("¥")
                        TextField("购买价格", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("购买日期", selection: $purchaseDate, displayedComponents: [.date])
                }
                
                // 图片选择
                Section(header: Text("图片")) {
                    HStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                                .frame(width: 100, height: 100)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        Button(action: {
                            activeSheet = .imagePicker
                        }) {
                            Text("选择图片")
                        }
                    }
                }
            }
            .navigationTitle("添加物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addAsset()
                        dismiss()
                    }
                    .disabled(name.isEmpty || value.isEmpty || Double(value) == nil)
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .imagePicker:
                    ImagePicker(selectedImage: $selectedImage)
                case .addCategory:
                    NewCategorySheet { newCategory in
                        selectedCategories.insert(newCategory)
                    }
                }
            }
        }
    }
    
    private func addAsset() {
        guard let valueDouble = Double(value) else { return }
        
        var imageName = "defaultAsset" // 默认图片名称
        var isCustomImage = false
        
        if let image = selectedImage {
            let newImageName = UUID().uuidString + ".jpg"
            if assetManager.saveImage(image, name: newImageName) {
                imageName = newImageName
                isCustomImage = true
            }
        }
        
        let newAsset = AssetItem(
            name: name,
            value: valueDouble,
            purchasePrice: Double(purchasePrice),
            purchaseDate: purchaseDate,
            imageName: imageName,
            categories: selectedCategories,
            description: description.isEmpty ? nil : description,
            isCustomImage: isCustomImage
        )
        
        assetManager.addItem(newAsset)
    }
    
    private func toggleCategory(_ category: AssetCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

// 分类选择按钮
private struct CategorySelectButton: View {
    let category: AssetCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : category.color)
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 60, height: 60)
            .background(isSelected ? category.color : Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

// 在添加物品时的新增分类视图
private struct NewCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    @State private var name = ""
    @State private var iconName = "tag.fill"
    @State private var color = Color.blue
    let onAdd: (AssetCategory) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    private let icons = [
        "tag.fill", "house.fill", "car.fill", "creditcard.fill",
        "laptopcomputer", "iphone", "applewatch", "gamecontroller.fill",
        "tshirt.fill", "books.vertical.fill", "fork.knife", "bed.double.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("分类名称", text: $name)
                    ColorPicker("分类颜色", selection: $color)
                }
                
                Section("选择图标") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                iconName = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(iconName == icon ? color : .primary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        iconName == icon ?
                                        color.opacity(0.2) : Color(.systemGray6)
                                    )
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("新增分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let newCategory = AssetCategory(
                            name: name,
                            iconName: iconName,
                            color: color
                        )
                        assetManager.addCategory(newCategory)
                        onAdd(newCategory)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddAssetView()
        .environmentObject(AssetManager())
} 
