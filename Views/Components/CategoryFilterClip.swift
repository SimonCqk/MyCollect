//
//  CategoryFilterClip.swift
//  MyCollect
//
//  Created by 冯先生 on 2025/2/20.
//

import SwiftUI

struct CategoryFilterChip: View {
    let category: AssetCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.iconName)
                Text(category.name)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? category.color.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? category.color : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 1)
            )
        }
    }
} 
