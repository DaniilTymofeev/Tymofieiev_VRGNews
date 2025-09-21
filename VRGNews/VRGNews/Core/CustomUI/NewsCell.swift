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
    
    private var formattedDescription: (text: String, hasMore: Bool) {
        let result = NewsTextFormatter.formatDescription(news.descriptionText, maxLength: 100)
        return (text: result.text, hasMore: result.hasMore)
    }
    
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
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("VRGNews_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 140, height: 100)
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
