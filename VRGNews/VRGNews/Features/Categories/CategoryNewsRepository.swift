//
//  CategoryNewsRepository.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Foundation
import RealmSwift

class CategoryNewsRepository {
    private let realmManager = RealmManager.shared
    private let networkManager = NetworkManager.shared
    
    // MARK: - Load News from API
    func loadNews(category: Category, page: Int = 1, pageSize: Int = 20) async throws -> (news: [News], totalResults: Int) {
        do {
            let result = try await networkManager.fetchCategoryNews(category: category, page: page, pageSize: pageSize)
            save(result.news, category: category)
            return (news: result.news, totalResults: result.totalResults)
        } catch {
            print("Error loading category news: \(error)")
            throw error
        }
    }
    
    // MARK: - First Load (Refresh) - Clear previous category and load new one
    func firstLoad(category: Category) async throws -> (news: [News], totalResults: Int) {
        // Clear all existing news for this category before loading new ones
        deleteAllForCategory(category)
        return try await loadNews(category: category, page: 1, pageSize: 20)
    }
    
    // MARK: - Load More (Pagination)
    func loadMore(category: Category, page: Int) async throws -> (news: [News], totalResults: Int) {
        return try await loadNews(category: category, page: page, pageSize: 20)
    }
    
    // MARK: - Save Operations
    func save(_ newsArray: [News], category: Category) {
        // Set category for all news items
        for news in newsArray {
            news.category = category.rawValue
        }
        realmManager.saveArray(newsArray)
    }
    
    // MARK: - Fetch Operations
    func fetchAllForCategory(_ category: Category) -> Results<News> {
        // Fetch all news for specific category, ordered by insertion timestamp
        let predicate = NSPredicate(format: "category == %@", category.rawValue)
        return realmManager.fetchFilteredAndSorted(News.self, predicate: predicate, by: "insertionTimestamp", ascending: true)
    }
    
    // MARK: - Delete Operations
    func deleteAllForCategory(_ category: Category) {
        // Delete all news for specific category
        let predicate = NSPredicate(format: "category == %@", category.rawValue)
        let newsToDelete = realmManager.fetchFiltered(News.self, predicate: predicate)
        
        // Use the generic delete method from RealmManager
        for news in newsToDelete {
            realmManager.delete(news)
        }
    }
    
    // MARK: - Check if category has news
    func hasNewsForCategory(_ category: Category) -> Bool {
        let predicate = NSPredicate(format: "category == %@", category.rawValue)
        let results = realmManager.fetchFiltered(News.self, predicate: predicate)
        return results.count > 0
    }
}
