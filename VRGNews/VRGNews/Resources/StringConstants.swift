//
//  StringConstants.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 19.09.2025.
//

import Foundation

enum StringConstants {
    
    // MARK: - Navigation & Titles
    enum Navigation {
        static let searchNews = "Search News"
        static let categories = "Categories"
    }
    
    // MARK: - Search
    enum Search {
        static let placeholder = "Search news..."
        static let loadingNews = "Loading news..."
        static let noNewsFound = "No news found"
        static let retry = "Retry"
    }
    
    // MARK: - Categories
    enum Categories {
        static let selectCategory = "Select Category"
        static let done = "Done"
        static let loadingCategoryNews = "Loading %@ news..."
        static let tryAgain = "Try Again"
        static let noNewsFoundCategory = "No news found"
        static let tryDifferentCategory = "Try selecting a different category or pull down to refresh"
        
        // Category names
        enum Names {
            static let general = "General"
            static let business = "Business"
            static let entertainment = "Entertainment"
            static let health = "Health"
            static let science = "Science"
            static let sports = "Sports"
            static let technology = "Technology"
        }
    }
    
    // MARK: - Loading & Pagination
    enum Loading {
        static let loadingMore = "Loading more..."
        static let more = "more"
        static let less = "less"
    }
    
    // MARK: - Errors
    enum Errors {
        static let somethingWentWrong = "Oops! Something went wrong"
        static let networkError = "Network request failed"
        static let cancelled = "cancelled"
        static let requestCancelled = "Request was cancelled (likely interrupted pull-to-refresh)"
    }
    
    // MARK: - Tab Bar
    enum TabBar {
        static let search = "Search"
        static let categories = "Categories"
    }
    
    // MARK: - News Cell
    enum NewsCell {
        static let noImagePlaceholder = "VRGNews_logo"
    }
    
    // MARK: - Date Formatting
    enum DateFormat {
        static let timeAgo = "%d ago"
        static let minutesAgo = "%dm ago"
        static let hoursAgo = "%dh ago"
        static let daysAgo = "%dd ago"
        static let weeksAgo = "%dw ago"
        static let monthsAgo = "%dmo ago"
        static let yearsAgo = "%dy ago"
    }
    
    // MARK: - API & Network
    enum API {
        static let apiKeyHeader = "X-Api-Key"
        static let languageParam = "language=en"
        static let pageParam = "page"
        static let pageSizeParam = "pageSize"
        static let queryParam = "q"
        static let categoryParam = "category"
    }
    
    // MARK: - Default Values
    enum Defaults {
        static let defaultSearchKeyword = "ukraine"
        static let defaultPageSize = 20
        static let defaultPage = 1
    }
    
    // MARK: - Log Messages
    enum Logs {
        static let foundLastSearchKeyword = "🔍 Found last search keyword in Realm: '%@'"
        static let noPreviousSearch = "🔍 No previous search found, using default: '%@'"
        static let foundLastCategory = "🔍 Found last selected category in Realm: '%@'"
        static let noPreviousCategory = "🔍 No previous category found, using default: '%@'"
        static let firstTimeLoading = "🚀 First time loading - fetching from API..."
        static let showingCachedData = "📱 Showing cached data from Realm (%d items)"
        static let startingForceRefresh = "🔄 Starting force refresh for keyword: '%@'"
        static let forceRefreshSuccessful = "✅ Force refresh successful: %d news items for keyword: '%@' (Total available: %d)"
        static let loadedPage = "📄 Loaded page %d: %d additional news items for category: '%@' (Total available: %d)"
        static let errorLoadingNews = "❌ Failed to first load news for keyword: '%@': %@"
        static let errorLoadingMore = "❌ Failed to load more news for category '%@': %@"
        static let requestCancelledWarning = "⚠️ Request was cancelled (likely interrupted pull-to-refresh)"
        static let errorLoadingNewsGeneric = "Error loading news: %@"
    }
    
    // MARK: - UI Elements
    enum UI {
        static let magnifyingglass = "magnifyingglass"
        static let squareGrid2x2 = "square.grid.2x2"
        static let chevronDown = "chevron.down"
        static let xmarkCircleFill = "xmark.circle.fill"
        static let exclamationmarkTriangle = "exclamationmark.triangle"
        static let newspaper = "newspaper"
    }
}
