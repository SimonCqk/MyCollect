import Foundation

struct MonthlyAssetData: Identifiable {
    let id = UUID()
    let month: Date
    let totalValue: Double
    
    // 格式化月份显示
    var monthDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: month)
    }
} 
