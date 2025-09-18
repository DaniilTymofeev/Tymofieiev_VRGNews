//
//  VRGNewsApp.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 17.09.2025.
//

import SwiftUI

@main
struct VRGNewsApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NewsSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }
        }
    }
}
