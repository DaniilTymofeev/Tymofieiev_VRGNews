//
//  SearchNewsViewModel.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Foundation
import RealmSwift
import SwiftUI
import Combine

@MainActor
class SearchNewsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var newsResults: Results<News>?
    @Published var searchText = ""
    
    private let searchNewsRepository = SearchNewsRepository()
    private var currentPage = 1
    private var totalLoadedItems = 0
    private var totalAvailableResults = 0
    private let pageSize = 20
    private var refreshTask: Task<Void, Never>?
    
    init() {
        loadInitialDataIfNeeded()
    }
    
    // MARK: - First Load / Refresh
    func firstLoad(keyword: String) async {
        guard !keyword.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        totalLoadedItems = 0
        
        do {
            let result = try await searchNewsRepository.firstLoad(keyword: keyword)
            refreshNewsList()
            totalLoadedItems = result.news.count
            totalAvailableResults = result.totalResults
            print("🔄 First load: \(result.news.count) news items for keyword: '\(keyword)' (Total available: \(result.totalResults))")
        } catch {
            // Check if it's a cancellation error (common with pull-to-refresh)
            if (error as NSError).code == NSURLErrorCancelled {
                print("⚠️ Request was cancelled (likely interrupted pull-to-refresh)")
                // Don't show error for cancelled requests
                errorMessage = nil
            } else {
                print("❌ Failed to first load news for keyword '\(keyword)': \(error.localizedDescription)")
                errorMessage = "Failed to load news: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Load More (Pagination)
    func loadMore(keyword: String) async {
        guard !keyword.isEmpty, !isLoadingMore, hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        // Add a small delay to be respectful to the API
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        
        do {
            let result = try await searchNewsRepository.loadMore(keyword: keyword, page: currentPage)
            refreshNewsList()
            totalLoadedItems += result.news.count
            totalAvailableResults = result.totalResults // Update total available
            
            print("📄 Loaded page \(currentPage): \(result.news.count) additional news items for keyword: '\(keyword)' (Total available: \(result.totalResults))")
            
            // If we got 0 items, we've reached the end of available content
            if result.news.count == 0 {
                print("🏁 No more items available for keyword '\(keyword)' - stopping pagination")
                currentPage -= 1 // Revert page increment since this page was empty
            }
        } catch {
            print("❌ Failed to load more news for keyword '\(keyword)': \(error.localizedDescription)")
            
            // Check if it's a rate limiting error (426) or similar
            if let httpError = error as? NetworkError,
               case .httpError(let statusCode) = httpError,
               statusCode >= 400 {
                print("🚫 API error \(statusCode) - stopping pagination to avoid rate limiting")
                currentPage -= 1 // Revert page increment
                // Don't show error message for rate limiting, just stop loading more
            } else {
                // Don't show error for load more, just log it
            }
        }
        
        isLoadingMore = false
    }
    
    // MARK: - Search (Alias for firstLoad)
    func performSearch(keyword: String) async {
        await firstLoad(keyword: keyword)
    }
    
    // MARK: - Retry Loading
    func retryLoading() {
        Task {
            await firstLoad(keyword: "ukraine")
        }
    }
    
    // MARK: - Pull to Refresh
    func refreshData() async {
        // Cancel any existing refresh task
        refreshTask?.cancel()
        
        // Create a new task that can't be cancelled
        refreshTask = Task {
            // Wait a bit to ensure refresh gesture is stable
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            // Force refresh by clearing existing data first
            await forceRefresh(keyword: searchText.isEmpty ? "ukraine" : searchText)
        }
        
        await refreshTask?.value
    }
    
    // MARK: - Force Refresh (non-cancellable)
    private func forceRefresh(keyword: String) async {
        print("🔄 Starting force refresh for keyword: '\(keyword)'")
        
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Retry mechanism - try up to 3 times
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                let result = try await searchNewsRepository.firstLoad(keyword: keyword)
                refreshNewsList()
                totalLoadedItems = result.news.count
                totalAvailableResults = result.totalResults
                currentPage = 1
                
                print("✅ Force refresh successful: \(result.news.count) news items for keyword: '\(keyword)' (Total available: \(result.totalResults))")
                isLoading = false
                return
                
            } catch {
                retryCount += 1
                
                if (error as NSError).code == NSURLErrorCancelled {
                    print("⚠️ Request cancelled, retrying... (attempt \(retryCount)/\(maxRetries))")
                    // Wait before retry
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
                } else {
                    print("❌ Force refresh failed: \(error.localizedDescription)")
                    errorMessage = "Failed to refresh: \(error.localizedDescription)"
                    isLoading = false
                    return
                }
            }
        }
        
        // If we get here, all retries failed
        print("❌ Force refresh failed after \(maxRetries) attempts")
        errorMessage = "Failed to refresh after multiple attempts"
        isLoading = false
    }
    
    // MARK: - Check if should load more
    func shouldLoadMore(for itemIndex: Int) -> Bool {
        guard let results = newsResults else { return false }
        let totalItems = results.count
        let loadMoreThreshold = totalItems - 3 // Load more when 3 items before end
        
        return itemIndex >= loadMoreThreshold && !isLoadingMore && hasMorePages
    }
    
    private func loadInitialDataIfNeeded() {
        // Try to find the last search keyword from Realm
        if let lastSearchKeyword = searchNewsRepository.getLastSearchKeyword() {
            searchText = lastSearchKeyword
            print("🔍 Found last search keyword in Realm: '\(lastSearchKeyword)'")
        } else {
            searchText = "ukraine" // Default value
            print("🔍 No previous search found, using default: 'ukraine'")
        }
        
        refreshNewsList()
        if newsResults?.isEmpty ?? true {
            print("🚀 First time loading - fetching from API...")
            Task {
                await firstLoad(keyword: searchText)
            }
        } else {
            let count = newsResults?.count ?? 0
            totalLoadedItems = count
            print("📱 Showing cached data from Realm (\(count) items)")
        }
    }
    
    private func refreshNewsList() {
        newsResults = searchNewsRepository.fetchAll()
    }
    
    // MARK: - Computed Properties
    var hasNews: Bool {
        guard let results = newsResults else { return false }
        return !results.isEmpty
    }
    
    var newsCount: Int {
        return newsResults?.count ?? 0
    }
    
    var hasMorePages: Bool {
        // More conservative pagination logic to avoid rate limiting
        // We have more pages if:
        // 1. We have loaded at least one page (totalLoadedItems > 0)
        // 2. We haven't loaded all available results yet
        // 3. We haven't hit any API errors recently
        // 4. We're not currently loading more
        // 5. We haven't made too many requests (conservative limit)
        let hasReasonableLimit = currentPage < 10 // Don't go beyond 10 pages to avoid rate limits
        return totalLoadedItems > 0 && totalLoadedItems < totalAvailableResults && hasReasonableLimit && !isLoadingMore
    }
    
    var isLoadingAny: Bool {
        return isLoading || isLoadingMore
    }
    
    // MARK: - Cleanup
    func cleanup() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
