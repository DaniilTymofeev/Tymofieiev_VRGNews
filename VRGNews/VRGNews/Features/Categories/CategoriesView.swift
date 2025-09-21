//
//  CategoriesView.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 19.09.2025.
//

import SwiftUI
import RealmSwift

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.isLoading && !viewModel.hasNews {
                        // Initial loading state
                        VStack {
                            Spacer()
                            VRGNewsLoadingView()
                            Text("Loading \(viewModel.selectedCategory.displayName) news...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Spacer()
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        // Error state
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Oops! Something went wrong")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button("Try Again") {
                                viewModel.retryLoading()
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(20)
                            
                            Spacer()
                        }
                    } else if !viewModel.hasNews {
                        // Empty state
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image(systemName: "newspaper")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No news found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Try selecting a different category or pull down to refresh")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                    } else if let results = viewModel.newsResults {
                        // News list with category header
                        List {
                            // Category Header Section
                            Section {
                                CategoryHeader(
                                    selectedCategory: viewModel.selectedCategory,
                                    onCategoryTapped: {
                                        viewModel.showingCategoryPicker = true
                                    }
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            }
                            
                            // News Items Section
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, news in
                                NewsCell(news: news, isAlternateColor: index % 2 == 1)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .onAppear {
                                        // Load more when approaching the end
                                        if viewModel.shouldLoadMore(for: index) {
                                            Task {
                                                await viewModel.loadMore(category: viewModel.selectedCategory)
                                            }
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            await viewModel.refreshData()
                        }
                        
                        // Loading more indicator at bottom
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                VRGNewsLoadingView()
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
                
                // Category Picker Overlay
                if viewModel.showingCategoryPicker {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showingCategoryPicker = false
                        }
                    
                    VStack(spacing: 0) {
                        // Position the picker right beneath the category header
                        Spacer()
                            .frame(height: 120) // Adjust this value to position right below header
                        
                        CategoryPickerView(
                            selectedCategory: viewModel.selectedCategory,
                            onCategorySelected: { category in
                                viewModel.selectCategory(category)
                            },
                            onDismiss: {
                                viewModel.showingCategoryPicker = false
                            }
                        )
                        .padding(.horizontal, 16) // Add horizontal padding
                        .transition(.move(edge: .bottom))
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle(viewModel.selectedCategory.displayName)
            .onDisappear {
                viewModel.cleanup()
            }
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}
