//
//  SearchNewsView.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 17.09.2025.
//

import SwiftUI
import RealmSwift

struct SearchNewsView: View {
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var newsResults: RealmSwift.Results<News>?
    
    private let searchRepository = SearchNewsRepository()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: performSearch)
                
                if isLoading {
                    ProgressView("Loading news...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Retry") {
                            loadInitialNews()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let results = newsResults, results.isEmpty {
                    VStack {
                        Image(systemName: "newspaper")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No news found")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let results = newsResults {
                    List(Array(results.enumerated()), id: \.element.id) { index, news in
                        NewsCell(news: news, isAlternateColor: index % 2 == 1)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color.white)
            .navigationTitle("Search News")
        }
        .background(Color.white)
        .preferredColorScheme(.light)
        .onAppear {
            refreshNewsList()
            if newsResults?.isEmpty ?? true {
                print("🚀 First time loading - fetching from API...")
                loadInitialNews()
            } else {
                print("📱 Showing cached data from Realm (\(newsResults?.count ?? 0) items)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadInitialNews() {
        Task {
            await performSearch(keyword: "ukraine")
        }
    }
    
    private func performSearch(keyword: String) async {
        guard !keyword.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await searchRepository.loadNews(keyword: keyword)
            await MainActor.run {
                refreshNewsList()
                let count = newsResults?.count ?? 0
                print("📰 Loaded \(count) news items for keyword: '\(keyword)'")
                isLoading = false
            }
        } catch {
            await MainActor.run {
                print("❌ Failed to load news for keyword '\(keyword)': \(error.localizedDescription)")
                errorMessage = "Failed to load news: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func refreshNewsList() {
        newsResults = searchRepository.fetchAll()
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
                .onChange(of: text) { newValue in
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
