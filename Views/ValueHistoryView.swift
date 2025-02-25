import SwiftUI
import Charts

struct ValueHistoryView: View {
    let itemId: UUID
    @EnvironmentObject private var assetManager: AssetManager
    @State private var showingAddValue = false
    @State private var showingDeleteAlert = false
    @State private var selectedRecord: ValueRecord?
    
    private var item: AssetItem? {
        assetManager.getItem(withId: itemId)
    }
    
    var body: some View {
        List {
            if let currentItem = item {
                // 价值概览
                ValueOverviewSection(item: currentItem)
                
                // 历史记录
                HistorySection(
                    item: currentItem,
                    selectedRecord: $selectedRecord,
                    showingDeleteAlert: $showingDeleteAlert
                )
            }
        }
        .navigationTitle("价值记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddValue = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddValue) {
            if let currentItem = item {
                AddValueView(item: currentItem)
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteRecord()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销")
        }
    }
    
    private func deleteRecord() {
        guard var currentItem = item,
              let record = selectedRecord else { return }
        
        if let index = currentItem.valueHistory.firstIndex(where: { $0.id == record.id }) {
            currentItem.valueHistory.remove(at: index)
            assetManager.updateItem(currentItem)
        }
    }
}

// 价值概览部分
private struct ValueOverviewSection: View {
    let item: AssetItem
    
    var body: some View {
        Section {
            VStack(spacing: 15) {
                // 当前价值
                ValueDisplay(
                    title: "当前价值",
                    value: item.value,
                    color: .blue
                )
                
                if let purchasePrice = item.purchasePrice {
                    Divider()
                    
                    // 购买价格
                    ValueDisplay(
                        title: "购买价格",
                        value: purchasePrice,
                        color: .secondary
                    )
                    
                    // 价值变化
                    if let change = item.valueChange {
                        Divider()
                        ValueChangeDisplay(change: change)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// 价值显示组件
private struct ValueDisplay: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("¥\(value, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
        }
    }
}

// 价值变化显示组件
private struct ValueChangeDisplay: View {
    let change: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("价值变化")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("¥\(abs(change), specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold))
            }
            .foregroundColor(change >= 0 ? .green : .red)
        }
    }
}

// 历史记录部分
private struct HistorySection: View {
    let item: AssetItem
    @Binding var selectedRecord: ValueRecord?
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        Section {
            if item.valueHistory.isEmpty {
                Text("暂无记录")
                    .foregroundColor(.secondary)
            } else {
                ForEach(item.valueHistory.sorted { $0.date > $1.date }) { record in
                    HistoryRow(record: record)
                        .contextMenu {
                            Button(role: .destructive) {
                                selectedRecord = record
                                showingDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
        } header: {
            Text("历史记录")
        }
    }
}

// 历史记录行组件
private struct HistoryRow: View {
    let record: ValueRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(date: .numeric, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("¥\(record.value, specifier: "%.2f")")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    NavigationView {
        ValueHistoryView(itemId: UUID())
            .environmentObject(AssetManager())
    }
}
