//
//  CategoriesViewModel.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import SwiftUI
import Combine
import RealmSwift

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var newsResults: Results<News>?
    @Published var selectedCategory: Category = .general
    @Published var showingCategoryPicker = false
    
    private let categoryNewsRepository = CategoryNewsRepository()
    private var currentPage = 1
    private var totalLoadedItems = 0
    private var totalAvailableResults = 0
    private let pageSize = 20
    private var refreshTask: Task<Void, Never>?
    
    init() {
        // Try to find the last selected category from Realm
        if let lastCategory = categoryNewsRepository.getLastSelectedCategory() {
            selectedCategory = lastCategory
            print("🔍 Found last selected category in Realm: '\(lastCategory.displayName)'")
        } else {
            selectedCategory = .general // Default value
            print("🔍 No previous category found, using default: 'general'")
        }
        loadInitialDataIfNeeded()
    }
    
    // MARK: - Load Initial Data
    func loadInitialDataIfNeeded() {
        // Check if we already have data for the selected category
        if !categoryNewsRepository.hasNewsForCategory(selectedCategory) {
            Task {
                await firstLoad(category: selectedCategory)
            }
        } else {
            refreshNewsList()
        }
    }
    
    // MARK: - First Load (Refresh)
    func firstLoad(category: Category) async {
        print("🔄 Starting first load for category: \(category.rawValue)")
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        totalLoadedItems = 0
        
        do {
            let result = try await categoryNewsRepository.firstLoad(category: category)
            refreshNewsList()
            totalLoadedItems = result.news.count
            totalAvailableResults = result.totalResults
            
            print("✅ First load successful: \(result.news.count) news items for category: '\(category.rawValue)' (Total available: \(result.totalResults))")
        } catch {
            // Check if it's a cancellation error
            if (error as NSError).code == NSURLErrorCancelled {
                print("⚠️ Request was cancelled (likely interrupted pull-to-refresh)")
                errorMessage = nil
            } else {
                print("❌ Failed to first load news for category '\(category.rawValue)': \(error.localizedDescription)")
                errorMessage = "Failed to load news: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Load More (Pagination)
    func loadMore(category: Category) async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        // Add a small delay to be respectful to the API
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        
        do {
            let result = try await categoryNewsRepository.loadMore(category: category, page: currentPage)
            refreshNewsList()
            totalLoadedItems += result.news.count
            totalAvailableResults = result.totalResults // Update total available
            
            print("📄 Loaded page \(currentPage): \(result.news.count) additional news items for category: '\(category.rawValue)' (Total available: \(result.totalResults))")
            
            // If we got 0 items, we've reached the end of available content
            if result.news.count == 0 {
                print("🏁 No more items available for category '\(category.rawValue)' - stopping pagination")
                currentPage -= 1 // Revert page increment since this page was empty
            }
        } catch {
            print("❌ Failed to load more news for category '\(category.rawValue)': \(error.localizedDescription)")
            
            // Check if it's a rate limiting error (426) or similar
            if let httpError = error as? NetworkError,
               case .httpError(let statusCode) = httpError,
               statusCode >= 400 {
                print("🚫 API error \(statusCode) - stopping pagination to avoid rate limiting")
                currentPage -= 1 // Revert page increment
                // Don't show error message for rate limiting, just stop loading more
                errorMessage = nil
            } else {
                errorMessage = "Failed to load more news: \(error.localizedDescription)"
            }
        }
        
        isLoadingMore = false
    }
    
    // MARK: - Category Selection
    func selectCategory(_ category: Category) {
        guard category != selectedCategory else { return }
        
        selectedCategory = category
        showingCategoryPicker = false
        
        // Load news for new category
        Task {
            await firstLoad(category: category)
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
            await forceRefresh(category: selectedCategory)
        }
        
        await refreshTask?.value
    }
    
    // MARK: - Force Refresh (non-cancellable)
    private func forceRefresh(category: Category) async {
        print("🔄 Starting force refresh for category: '\(category.rawValue)'")
        
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Retry mechanism - try up to 3 times
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                let result = try await categoryNewsRepository.firstLoad(category: category)
                refreshNewsList()
                totalLoadedItems = result.news.count
                totalAvailableResults = result.totalResults
                currentPage = 1
                
                print("✅ Force refresh successful: \(result.news.count) news items for category: '\(category.rawValue)' (Total available: \(result.totalResults))")
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
        
        // Load more when we're 3 items from the end
        return itemIndex >= totalItems - 3 && hasMorePages && !isLoadingMore
    }
    
    // MARK: - Refresh news list from Realm
    func refreshNewsList() {
        newsResults = categoryNewsRepository.fetchAllForCategory(selectedCategory)
    }
    
    // MARK: - Retry loading
    func retryLoading() {
        Task {
            await firstLoad(category: selectedCategory)
        }
    }
    
    // MARK: - Computed Properties
    var hasNews: Bool {
        return newsResults?.count ?? 0 > 0
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
