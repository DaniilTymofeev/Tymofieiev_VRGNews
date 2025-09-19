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
            VStack {
                SearchBar(text: $viewModel.searchText, onSearch: viewModel.performSearch)
                
                if viewModel.isLoading {
                    ProgressView("Loading news...")
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
                    VStack {
                        Image(systemName: "newspaper")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No news found")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let results = viewModel.newsResults {
                    List(Array(results.enumerated()), id: \.element.id) { index, news in
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
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.refreshData()
                    }
                    
                    // Loading more indicator at bottom
                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView("Loading more...")
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("Search News")
        }
        .background(Color.white)
        .preferredColorScheme(.light)
        .onDisappear {
            viewModel.cleanup()
        }
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
