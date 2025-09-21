//
//  News.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import Realm
import RealmSwift
import SwiftUI

class News: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var source: Source?
    @Persisted var author: String?
    @Persisted var title: String
    @Persisted var descriptionText: String?
    @Persisted var url: String
    @Persisted var urlToImage: String?
    @Persisted var publishedAt: Date?
    @Persisted var content: String?
    @Persisted var category: String? // nil for search
    @Persisted var searchKeyword: String? // nil for categories
    @Persisted var insertionTimestamp: Date = Date() // Track when item was added to Realm
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, descriptionText, url, urlToImage, publishedAt, content
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.author = try? container.decode(String.self, forKey: .author)
        self.title = try container.decode(String.self, forKey: .title)
        self.descriptionText = try? container.decode(String.self, forKey: .descriptionText)
        self.url = try container.decode(String.self, forKey: .url)
        self.urlToImage = try? container.decode(String.self, forKey: .urlToImage)
        self.content = try? container.decode(String.self, forKey: .content)
        self.source = try? container.decode(Source.self, forKey: .source)
        
        if let publishedAtString = try? container.decode(String.self, forKey: .publishedAt) { // format to Date
            let formatter = ISO8601DateFormatter()
            self.publishedAt = formatter.date(from: publishedAtString)
        }
    }
}

class Source: Object, Codable {
    @Persisted var id: String?
    @Persisted var name: String?
}
