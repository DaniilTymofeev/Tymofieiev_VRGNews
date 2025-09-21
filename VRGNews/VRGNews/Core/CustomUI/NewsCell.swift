//
//  NewsCell.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 18.09.2025.
//

import SwiftUI

struct NewsCell: View {
    let news: News
    let isAlternateColor: Bool
    
    var topBorderColor: Color {
        isAlternateColor ? .red : .blue
    }
    
    // Format description text
    private var formattedDescription: (text: String, hasMore: Bool) {
        let result = NewsTextFormatter.formatDescription(news.descriptionText, maxLength: 100)
        return (text: result.text, hasMore: result.hasMore)
    }
    
    // Format content text
    private var formattedContent: (text: String, hasMore: Bool) {
        let result = NewsTextFormatter.formatContent(news.content, maxLength: 150)
        return (text: result.text, hasMore: result.hasMore)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(topBorderColor)
                .frame(height: 3)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if let sourceName = news.source?.name {
                        Text(sourceName)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if let publishedAt = news.publishedAt {
                        Text(formatDate(publishedAt))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(news.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: news.urlToImage ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Try .fit for different behavior
                    } placeholder: {
                        Image("VRGNews_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 140, height: 100) // Wider but same height
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if !formattedDescription.text.isEmpty {
                            Text(formattedDescription.text)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .minimumScaleFactor(0.6)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: false)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 100)
                    .clipped()
                }
                .padding(.bottom, 8)
                
                if !formattedContent.text.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedContent.text)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, news.author != nil ? 4 : 0)
                        
                        if formattedContent.hasMore {
                            Text("more")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .underline()
                                .padding(.bottom, news.author != nil ? 4 : 0)
                        }
                    }
                }
                
                if let author = news.author {
                    HStack {
                        Spacer()
                        Text(author)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            if let url = URL(string: news.url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

//#Preview {
//    let mockNews = News()
//    mockNews.source = Source()
//    mockNews.source?.name = "BBC News"
//    mockNews.author = "Jude Sheerin"
//    mockNews.title = "Zelensky and allies head to White House for Ukraine talks"
//    mockNews.descriptionText = "European leaders will join Zelensky as he attends a crunch meeting with Trump on the Russia-Ukraine war."
//    mockNews.url = "https://www.bbc.com/news/articles/cm21j1ve817o"
//    mockNews.urlToImage = "https://ichef.bbci.co.uk/news/1024/branded_news/6ed8/live/f6c6ada0-7bb8-11f0-a34f-318be3fb0481.jpg"
//    mockNews.publishedAt = Date()
//    mockNews.content = "US President Donald Trump will host Volodymyr Zelensky on Monday for their first meeting..."
//
//    return VStack {
//        NewsCell(news: mockNews, isAlternateColor: false)
//        NewsCell(news: mockNews, isAlternateColor: true)
//    }
//    .padding()
//}
