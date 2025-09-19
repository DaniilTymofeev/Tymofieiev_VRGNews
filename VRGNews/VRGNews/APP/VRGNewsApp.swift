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
                .preferredColorScheme(.light) // Force light mode
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            SearchNewsView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }
        }
        .background(Color.white)
        .preferredColorScheme(.light)
        .onAppear {
            // Additional iOS-specific settings to force light mode
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = .light
            }
        }
    }
}
