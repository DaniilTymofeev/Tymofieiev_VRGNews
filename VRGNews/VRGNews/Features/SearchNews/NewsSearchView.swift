//
//  NewsSearchView.swift
//  VRGNews
//
//  Created by Danil Tymofeev on 17.09.2025.
//

import SwiftUI

struct NewsSearchView: View {
    @State private var searchText = ""
    
    private let mockNews: [News] = {
        let news1 = News()
        news1.source = Source()
        news1.source?.name = "BBC News"
        news1.author = "Jude Sheerin"
        news1.title = "Zelensky and allies head to White House for Ukraine talks"
        news1.descriptionText = "European leaders will join Zelensky as he attends a crunch meeting with Trump on the Russia-Ukraine war."
        news1.url = "https://www.bbc.com/news/articles/cm21j1ve817o"
        news1.urlToImage = "https://ichef.bbci.co.uk/news/1024/branded_news/6ed8/live/f6c6ada0-7bb8-11f0-a34f-318be3fb0481.jpg"
        news1.content = "US President Donald Trump will host Volodymyr Zelensky on Monday for their first meeting since the pair's heated exchange in the White House earlier this year - but this time the Ukrain… [+4851 chars]"
        
        // Parse the published date
        let formatter = ISO8601DateFormatter()
        news1.publishedAt = formatter.date(from: "2025-08-18T00:09:03Z")
        
        let news2 = News()
        news2.source = Source()
        news2.source?.name = "Wired"
        news2.author = "Riccardo Piccolo"
        news2.title = "Here's What to Know About Poland Shooting Down Russian Drones"
        news2.descriptionText = "On Wednesday morning, Poland shot down several Russian drones that entered its airspace—a first since Moscow's invasion of Ukraine."
        news2.url = "https://www.wired.com/story/poland-shoots-down-russian-drones/"
        news2.urlToImage = "https://media.wired.com/photos/68c173a65f25f488aea013dd/191:100/w_1280,c_limit/2234013675"
        news2.content = "Early Wednesday morning, Poland shot down several Russian drones that had violated its airspace during a massive strike against western Ukraine."
        news2.publishedAt = formatter.date(from: "2025-09-10T13:58:37Z")
        
        let news3 = News()
        news3.source = Source()
        news3.source?.name = "BBC News"
        news3.author = nil
        news3.title = "Beaten and held in Russia for three years - but never charged with a crime"
        news3.descriptionText = "Russia imprisoned Dmytro shortly after its invasion of Ukraine in 2022. He was freed last month."
        news3.url = "https://www.bbc.com/news/articles/cm28674vnp6o"
        news3.urlToImage = "https://ichef.bbci.co.uk/news/1024/branded_news/da02/live/49ac2c10-924e-11f0-9cf6-cbf3e73ce2b9.jpg"
        news3.content = "Sarah RainsfordSouthern and eastern Europe correspondent, Kyiv region"
        news3.publishedAt = formatter.date(from: "2025-09-16T05:00:37Z")
        
        return [news1, news2, news3]
    }()
    
    var filteredNews: [News] {
        if searchText.isEmpty {
            return mockNews
        } else {
            return mockNews.filter { news in
                news.title.localizedCaseInsensitiveContains(searchText) ||
                news.descriptionText?.localizedCaseInsensitiveContains(searchText) == true ||
                news.source?.name?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                
                List(filteredNews.indices, id: \.self) { index in
                    let news = filteredNews[index]
                    NewsCell(news: news, isAlternateColor: index % 2 == 1)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(PlainListStyle())
                .background(Color.white)
            }
            .background(Color.white)
            .navigationTitle("Search News")
        }
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search news...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

//#Preview {
//    NewsSearchView()
//}
