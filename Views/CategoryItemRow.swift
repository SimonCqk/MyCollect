import SwiftUI

struct CategoryItemRow: View {
    @EnvironmentObject private var assetManager: AssetManager
    let item: AssetItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 物品图片
            if item.isCustomImage {
                if let image = assetManager.loadImage(name: item.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // ... 其他视图内容保持不变 ...
        }
    }
} 
