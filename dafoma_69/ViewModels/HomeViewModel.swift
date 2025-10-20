//
//  HomeViewModel.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: ArticleCategory? = nil
    @Published var filteredArticles: [Article] = []
    @Published var featuredArticles: [Article] = []
    @Published var userProgress = UserProgress()
    @Published var isLoading = false
    @Published var showingCategoryFilter = false
    
    private let articleService: ArticleService
    private var cancellables = Set<AnyCancellable>()
    
    init(articleService: ArticleService) {
        self.articleService = articleService
        
        setupBindings()
        loadUserProgress()
        refreshContent()
    }
    
    private func setupBindings() {
        // Bind search text and category changes to filter articles
        Publishers.CombineLatest($searchText, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, category in
                self?.filterArticles(searchText: searchText, category: category)
            }
            .store(in: &cancellables)
        
        // Bind article service changes
        articleService.$articles
            .sink { [weak self] _ in
                self?.filterArticles(searchText: self?.searchText ?? "", category: self?.selectedCategory)
            }
            .store(in: &cancellables)
        
        articleService.$featuredArticles
            .assign(to: \.featuredArticles, on: self)
            .store(in: &cancellables)
        
    }
    
    private func filterArticles(searchText: String, category: ArticleCategory?) {
        var articles = articleService.articles
        
        // Filter by category
        if let category = category {
            articles = articles.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.content.localizedCaseInsensitiveContains(searchText) ||
                article.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        filteredArticles = articles
    }
    
    func refreshContent() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func selectCategory(_ category: ArticleCategory?) {
        selectedCategory = category
        showingCategoryFilter = false
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
    }
    
    func toggleBookmark(for article: Article) {
        articleService.toggleBookmark(for: article)
        
        // Update user progress
        if article.isBookmarked {
            userProgress.bookmarkedArticles.remove(article.id)
        } else {
            userProgress.bookmarkedArticles.insert(article.id)
        }
        saveUserProgress()
    }
    
    func markArticleAsRead(_ article: Article) {
        userProgress.articlesRead.insert(article.id)
        userProgress.totalReadingTime += article.readingTime
        
        // Update streak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastReadDate = userProgress.lastReadDate {
            let lastReadDay = calendar.startOfDay(for: lastReadDate)
            let daysDifference = calendar.dateComponents([.day], from: lastReadDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                userProgress.streakDays += 1
            } else if daysDifference > 1 {
                // Streak broken
                userProgress.streakDays = 1
            }
            // If daysDifference == 0, same day, don't change streak
        } else {
            // First article read
            userProgress.streakDays = 1
        }
        
        userProgress.lastReadDate = Date()
        saveUserProgress()
    }
    
    func getReadingProgress() -> Double {
        let totalArticles = articleService.articles.count
        let readArticles = userProgress.articlesRead.count
        return totalArticles > 0 ? Double(readArticles) / Double(totalArticles) : 0.0
    }
    
    func getRecommendedArticles() -> [Article] {
        // Simple recommendation algorithm
        var recommended: [Article] = []
        
        // Add articles from categories the user has read before
        let readArticles = articleService.articles.filter { userProgress.articlesRead.contains($0.id) }
        let preferredCategories = Set(readArticles.map { $0.category })
        
        for category in preferredCategories {
            let categoryArticles = articleService.getArticles(for: category)
                .filter { !userProgress.articlesRead.contains($0.id) }
            recommended.append(contentsOf: categoryArticles.prefix(1))
        }
        
        // Fill remaining slots with unread articles
        let unreadArticles = articleService.articles.filter { !userProgress.articlesRead.contains($0.id) }
        recommended.append(contentsOf: unreadArticles.prefix(5 - recommended.count))
        
        return Array(recommended.prefix(5))
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        }
    }
    
    private func saveUserProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: "userProgress")
        }
    }
    
    // MARK: - Computed Properties
    
    var hasActiveFilters: Bool {
        !searchText.isEmpty || selectedCategory != nil
    }
    
    var displayedArticles: [Article] {
        hasActiveFilters ? filteredArticles : articleService.articles
    }
    
    var categoriesWithCounts: [(category: ArticleCategory, count: Int)] {
        ArticleCategory.allCases.map { category in
            let count = articleService.getArticles(for: category).count
            return (category: category, count: count)
        }
    }
}

