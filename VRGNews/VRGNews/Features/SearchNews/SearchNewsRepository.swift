//
//  NewsRepository.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Foundation
import RealmSwift

class SearchNewsRepository {
    private let realmManager = RealmManager.shared
    private let networkManager = NetworkManager.shared
    
    // MARK: - Load News from API
    func loadNews(keyword: String, page: Int = 1, pageSize: Int = 20) async throws -> (news: [News], totalResults: Int) {
        do {
            let result = try await networkManager.searchNews(query: keyword, page: page, pageSize: pageSize)
            save(result.news, searchKeyword: keyword)
            return (news: result.news, totalResults: result.totalResults)
        } catch {
            print("Error loading news: \(error)")
            throw error
        }
    }
    
    // MARK: - First Load (Refresh)
    func firstLoad(keyword: String) async throws -> (news: [News], totalResults: Int) {
        // Clear all existing news before loading new ones
        deleteAll()
        return try await loadNews(keyword: keyword, page: 1, pageSize: 20)
    }
    
    // MARK: - Load More (Pagination)
    func loadMore(keyword: String, page: Int) async throws -> (news: [News], totalResults: Int) {
        return try await loadNews(keyword: keyword, page: page, pageSize: 20)
    }
    
    // MARK: - Save Operations
    func save(_ newsArray: [News], searchKeyword: String) {
        // Set category to nil and searchKeyword for all news items
        for news in newsArray {
            news.category = nil
            news.searchKeyword = searchKeyword
        }
        realmManager.saveArray(newsArray)
    }
    
    // MARK: - Fetch Operations
    func fetchAll() -> Results<News> {
        // Fetch all news with category field as nil, ordered by insertion timestamp (chronological order of loading)
        let predicate = NSPredicate(format: "category == nil")
        return realmManager.fetchFilteredAndSorted(News.self, predicate: predicate, by: "insertionTimestamp", ascending: true)
    }
    
    // MARK: - Last Search Keyword
    func getLastSearchKeyword() -> String? {
        // Find the most recent news item with a searchKeyword
        let predicate = NSPredicate(format: "searchKeyword != nil")
        let results = realmManager.fetchFilteredAndSorted(News.self, predicate: predicate, by: "insertionTimestamp", ascending: false)
        
        if let lastNews = results.first {
            print("🔍 Found last search keyword in Realm: '\(lastNews.searchKeyword ?? "nil")'")
            return lastNews.searchKeyword
        }
        
        print("🔍 No previous search keyword found in Realm")
        return nil
    }
    
    // MARK: - Delete Operations
    func deleteAll() {
        // Delete all news with category field as nil
        let predicate = NSPredicate(format: "category == nil")
        let newsToDelete = realmManager.fetchFiltered(News.self, predicate: predicate)
        
        // Use the generic delete method from RealmManager
        for news in newsToDelete {
            realmManager.delete(news)
        }
    }
}
