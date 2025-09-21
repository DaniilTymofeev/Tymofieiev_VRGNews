//
//  NetworkManager.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Foundation
import RealmSwift

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Search News
    func searchNews(query: String, page: Int = 1, pageSize: Int = 20) async throws -> (news: [News], totalResults: Int) {
        guard !query.isEmpty else { return ([], 0) }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(APIConstants.searchNewsURL)\(encodedQuery)&language=en&page=\(page)&pageSize=\(pageSize)"
        
        return try await performRequest(urlString: urlString)
    }
    
    func fetchCategoryNews(category: Category, page: Int = 1, pageSize: Int = 20) async throws -> (news: [News], totalResults: Int) {
        let urlString = "\(APIConstants.categoryNewsURL)\(category.rawValue)&language=en&page=\(page)&pageSize=\(pageSize)"
        
        return try await performRequest(urlString: urlString)
    }
    
    // MARK: - Private Methods
    private func performRequest(urlString: String) async throws -> (news: [News], totalResults: Int) {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIConstants.apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            let parsedNews = parseArticlesToNews(newsResponse.articles)
            
            return (news: parsedNews, totalResults: newsResponse.totalResults)
            
        } catch {
            // Don't log cancellation errors as they're expected
            if (error as NSError).code != NSURLErrorCancelled {
                print("Network request failed: \(error)")
            }
            throw error
        }
    }
    
    private func parseArticlesToNews(_ articles: [NewsArticle]) -> [News] {
        return articles.compactMap { article in
            let news = News()
            news.id = article.url // Use URL as unique identifier
            news.source = Source()
            news.source?.id = article.source.id
            news.source?.name = article.source.name
            news.author = article.author
            news.title = article.title
            news.descriptionText = article.description
            news.url = article.url
            news.urlToImage = article.urlToImage
            news.content = article.content
            
            // Parse published date
            if let publishedAtString = article.publishedAt {
                let formatter = ISO8601DateFormatter()
                news.publishedAt = formatter.date(from: publishedAtString)
            }
            
            // Set insertion timestamp to current time (this will be overridden if already exists)
            news.insertionTimestamp = Date()
            
            return news
        }
    }
    
//    private func saveNewsToRealm(_ articles: [NewsArticle]) async {
//        let realm = try! Realm()
//        
//        try! realm.write {
//            for article in articles {
//                let news = News()
//                news.id = article.url // Use URL as unique identifier
//                news.source = Source()
//                news.source?.id = article.source.id
//                news.source?.name = article.source.name
//                news.author = article.author
//                news.title = article.title
//                news.descriptionText = article.description
//                news.url = article.url
//                news.urlToImage = article.urlToImage
//                news.content = article.content
//                
//                // Parse published date
//                if let publishedAtString = article.publishedAt {
//                    let formatter = ISO8601DateFormatter()
//                    news.publishedAt = formatter.date(from: publishedAtString)
//                }
//                
//                // Check if news already exists
//                if realm.object(ofType: News.self, forPrimaryKey: news.id) == nil {
//                    realm.add(news)
//                } else {
//                    // Update existing news
//                    realm.add(news, update: .modified)
//                }
//            }
//        }
//    }
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

