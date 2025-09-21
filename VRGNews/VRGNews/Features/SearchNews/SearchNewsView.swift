//
//  SearchNewsView.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 17.09.2025.
//

import SwiftUI
import RealmSwift

struct SearchNewsView: View {
    @StateObject private var viewModel = SearchNewsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        VStack {
                            VRGNewsLoadingView()
                            Text("Loading news...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Retry") {
                                viewModel.retryLoading()
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.hasNews {
                        // Empty state with search bar
                        List {
                            // Search Bar Section
                            Section {
                                SearchBar(text: $viewModel.searchText, onSearch: viewModel.performSearch)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            }
                            
                            // Empty state message
                            Section {
                                VStack {
                                    Image(systemName: "newspaper")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No news found")
                                        .foregroundColor(.secondary)
                                        .font(.title2)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 50, leading: 16, bottom: 50, trailing: 16))
                            }
                        }
                        .listStyle(PlainListStyle())
                    } else if let results = viewModel.newsResults {
                        // News list with search bar
                        List {
                            // Search Bar Section
                            Section {
                                SearchBar(text: $viewModel.searchText, onSearch: viewModel.performSearch)
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
                                                await viewModel.loadMore(keyword: viewModel.searchText.isEmpty ? "ukraine" : viewModel.searchText)
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
            }
            .navigationTitle("Search News")
            .onDisappear {
                viewModel.cleanup()
            }
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: (String) async -> Void
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search news...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    searchTask?.cancel()
                    searchTask = Task {
                        await onSearch(text)
                    }
                }
                .onChange(of: text) { _, newValue in
                    // Cancel previous search
                    searchTask?.cancel()
                    
                    // Debounce search - wait 1 second before searching
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        if !Task.isCancelled {
                            await onSearch(newValue)
                        }
                    }
                }
            
            // Clear button - only show when there's text
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    searchTask?.cancel() // Cancel any pending search
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}