//
//  MainTabView.swift
//  MyCollect
//
//  Created by 冯先生 on 2025/2/20.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var assetManager = AssetManager()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("物品", systemImage: "house.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("统计", systemImage: "chart.pie.fill")
                }
        }
        .environmentObject(assetManager)
    }
} 
