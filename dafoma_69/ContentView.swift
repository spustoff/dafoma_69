//
//  ContentView.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import SwiftUI

struct ContentView: View {
    let articleService: ArticleService
    
    @State private var selectedTab = 0
    @StateObject private var homeViewModel: HomeViewModel
    
    init(articleService: ArticleService) {
        self.articleService = articleService
        self._homeViewModel = StateObject(wrappedValue: HomeViewModel(articleService: articleService))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(articleService: articleService)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Categories Tab
            CategoriesView(articleService: articleService)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "square.grid.2x2.fill" : "square.grid.2x2")
                    Text("Categories")
                }
                .tag(1)
            
            // Bookmarks Tab
            BookmarksView(articleService: articleService)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "bookmark.fill" : "bookmark")
                    Text("Bookmarks")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(.cognityPrimary)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ArticleCompleted"))) { notification in
            if let article = notification.object as? Article {
                homeViewModel.markArticleAsRead(article)
            }
        }
    }
}

// MARK: - Categories View
struct CategoriesView: View {
    let articleService: ArticleService
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cognityBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(ArticleCategory.allCases, id: \.self) { category in
                            CategorySectionView(
                                category: category,
                                articles: articleService.getArticles(for: category)
                            ) { article in
                                selectedArticle = article
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                DetailView(article: article, articleService: articleService)
            }
        }
    }
}

struct CategorySectionView: View {
    let category: ArticleCategory
    let articles: [Article]
    let onArticleTap: (Article) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(category.swiftUIColor)
                
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Text("\(articles.count)")
                    .font(.caption)
                    .foregroundColor(.cognityTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cognityCardBackground)
                    .cornerRadius(8)
            }
            
            if articles.isEmpty {
                Text("No articles in this category yet")
                    .font(.subheadline)
                    .foregroundColor(.cognityTextSecondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.cognityCardBackground)
                    .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(articles.prefix(3)) { article in
                        CategoryArticleRow(article: article) {
                            onArticleTap(article)
                        }
                    }
                    
                    if articles.count > 3 {
                        Button("View All \(articles.count) Articles") {
                            // Navigate to category detail view
                        }
                        .font(.subheadline)
                        .foregroundColor(category.swiftUIColor)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cognityCardBackground)
        .cornerRadius(16)
    }
}

struct CategoryArticleRow: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.cognityTextPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack {
                        DifficultyBadge(difficulty: article.difficulty)
                        
                        Spacer()
                        
                        Text("\(article.readingTime) min")
                            .font(.caption)
                            .foregroundColor(.cognityTextSecondary)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.cognityTextSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.cognityBackground.opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bookmarks View
struct BookmarksView: View {
    let articleService: ArticleService
    @State private var selectedArticle: Article?
    
    var bookmarkedArticles: [Article] {
        articleService.getBookmarkedArticles()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cognityBackground
                    .ignoresSafeArea()
                
                if bookmarkedArticles.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 60))
                            .foregroundColor(.cognityTextSecondary)
                        
                        VStack(spacing: 8) {
                            Text("No Bookmarks Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.cognityTextPrimary)
                            
                            Text("Bookmark articles to read them later")
                                .font(.subheadline)
                                .foregroundColor(.cognityTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(bookmarkedArticles) { article in
                                ArticleCard(
                                    article: article,
                                    isBookmarked: true,
                                    isRead: false
                                ) {
                                    selectedArticle = article
                                } onBookmark: {
                                    articleService.toggleBookmark(for: article)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                DetailView(article: article, articleService: articleService)
            }
        }
    }
}

#Preview {
    ContentView(articleService: ArticleService())
}
