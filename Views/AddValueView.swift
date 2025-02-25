//
//  AddValueView.swift
//  MyCollect
//
//  Created by 冯先生 on 2025/2/20.
//

import SwiftUI

struct AddValueView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var assetManager: AssetManager
    
    let item: AssetItem
    @State private var value = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("¥")
                        TextField("价值", text: $value)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("日期", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("添加记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addValue()
                        dismiss()
                    }
                    .disabled(value.isEmpty || Double(value) == nil)
                }
            }
        }
    }
    
    private func addValue() {
        guard var updatedItem = assetManager.getItem(withId: item.id),
              let valueDouble = Double(value) else { return }
        
        let record = ValueRecord(
            id: UUID(),
            date: date,
            value: valueDouble
        )
        
        updatedItem.valueHistory.append(record)
        updatedItem.value = valueDouble // 更新当前价值
        assetManager.updateItem(updatedItem)
    }
}

#Preview {
    AddValueView(item: AssetItem(
        name: "示例物品",
        value: 1000,
        imageName: "defaultAsset",
        categories: []
    ))
    .environmentObject(AssetManager())
}
