import SwiftUI
import Foundation

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    
    @State private var name = ""
    @State private var selectedIcon = "star"
    @State private var selectedColor = Color.blue
    
    // 预定义的图标选项
    private let iconOptions = [
        "star", "heart", "house", "car", "airplane", "bag",
        "creditcard", "banknote", "gift", "camera", "desktop",
        "gamecontroller", "headphones", "tv", "watch", "iphone"
    ]
    
    // 预定义的颜色选项
    private let colorOptions: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink,
        .yellow, .brown, .mint, .cyan, .indigo, .teal
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // 名称输入
                Section(header: Text("名称")) {
                    TextField("分类名称", text: $name)
                }
                
                // 图标选择
                Section(header: Text("图标")) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 10) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .primary)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 颜色选择
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 10) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white, lineWidth: 2)
                                            .padding(2)
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                selectedColor == color ? color : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 1)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("添加分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addCategory()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addCategory() {
        let newCategory = AssetCategory(
            name: name,
            iconName: selectedIcon,
            color: selectedColor
        )
        assetManager.addCategory(newCategory)
    }
}

#Preview {
    AddCategoryView()
        .environmentObject(AssetManager())
} 
