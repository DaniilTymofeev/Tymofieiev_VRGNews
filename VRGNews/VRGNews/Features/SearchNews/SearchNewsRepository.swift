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
    func loadNews(keyword: String) async throws {
        do {
            let result = try await networkManager.searchNews(query: keyword)
            save(result.news)
        } catch {
            print("Error loading news: \(error)")
            throw error
        }
    }
    
    // MARK: - Save Operations
    func save(_ newsArray: [News]) {
        // Set category to nil for all news items
        for news in newsArray {
            news.category = nil
        }
        realmManager.saveArray(newsArray)
    }
    
    // MARK: - Fetch Operations
    func fetchAll() -> Results<News> {
        // Fetch all news with category field as nil
        let predicate = NSPredicate(format: "category == nil")
        return realmManager.fetchFilteredAndSorted(News.self, predicate: predicate, by: "publishedAt", ascending: false)
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
