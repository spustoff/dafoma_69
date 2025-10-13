//
//  HomeView.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import SwiftUI

struct HomeView: View {
    let articleService: ArticleService
    let healthKitService: HealthKitService
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedArticle: Article?
    
    init(articleService: ArticleService, healthKitService: HealthKitService) {
        self.articleService = articleService
        self.healthKitService = healthKitService
        self._viewModel = StateObject(wrappedValue: HomeViewModel(articleService: articleService, healthKitService: healthKitService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cognityBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header with search
                        headerSection
                        
                        // Health insights (if available)
                        if !viewModel.healthInsights.isEmpty {
                            healthInsightsSection
                        }
                        
                        // Featured articles
                        featuredArticlesSection
                        
                        // Categories
                        categoriesSection
                        
                        // All articles or filtered results
                        articlesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Account for tab bar
                }
                .refreshable {
                    viewModel.refreshContent()
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedArticle) { article in
                DetailView(article: article, articleService: articleService, healthKitService: healthKitService)
            }
            .sheet(isPresented: $viewModel.showingCategoryFilter) {
                CategoryFilterView(viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Welcome text
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.cognityTextSecondary)
                    
                    Text("CognityPin")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.cognityTextPrimary)
                }
                
                Spacer()
                
                // Stats button
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Text("\(viewModel.userProgress.streakDays)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.cognityPrimary)
                        
                        Text("day streak")
                            .font(.caption)
                            .foregroundColor(.cognityTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.cognityCardBackground)
                    .cornerRadius(12)
                }
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.cognityTextSecondary)
                
                TextField("Search articles...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.cognityTextPrimary)
                
                if viewModel.hasActiveFilters {
                    Button(action: viewModel.clearFilters) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.cognityTextSecondary)
                    }
                }
                
                Button(action: { viewModel.showingCategoryFilter = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(viewModel.selectedCategory != nil ? .cognityPrimary : .cognityTextSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.cognityCardBackground)
            .cornerRadius(12)
        }
        .padding(.top, 10)
    }
    
    private var healthInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.cognitySecondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.healthInsights) { insight in
                        HealthInsightCard(insight: insight)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
    }
    
    private var featuredArticlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundColor(.cognityPrimary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.featuredArticles) { article in
                        FeaturedArticleCard(article: article) {
                            selectedArticle = article
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.cognityTextPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ArticleCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            category: category,
                            isSelected: viewModel.selectedCategory == category,
                            count: viewModel.categoriesWithCounts.first { $0.category == category }?.count ?? 0
                        ) {
                            viewModel.selectCategory(viewModel.selectedCategory == category ? nil : category)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
    }
    
    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.hasActiveFilters ? "Search Results" : "All Articles")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.displayedArticles.count) articles")
                    .font(.caption)
                    .foregroundColor(.cognityTextSecondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.displayedArticles) { article in
                    ArticleCard(
                        article: article,
                        isBookmarked: viewModel.userProgress.bookmarkedArticles.contains(article.id),
                        isRead: viewModel.userProgress.articlesRead.contains(article.id)
                    ) {
                        selectedArticle = article
                    } onBookmark: {
                        viewModel.toggleBookmark(for: article)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct HealthInsightCard: View {
    let insight: HealthInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Text("\(Int(insight.value)) \(insight.unit)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.cognitySecondary)
            }
            
            Text(insight.description)
                .font(.caption)
                .foregroundColor(.cognityTextSecondary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(width: 200)
        .background(Color.cognityCardBackground)
        .cornerRadius(12)
    }
}

struct FeaturedArticleCard: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Category and difficulty
                HStack {
                    CategoryBadge(category: article.category)
                    
                    Spacer()
                    
                    DifficultyBadge(difficulty: article.difficulty)
                }
                
                // Title
                Text(article.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Reading time
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.cognityTextSecondary)
                    
                    Text("\(article.readingTime) min read")
                        .font(.caption)
                        .foregroundColor(.cognityTextSecondary)
                    
                    Spacer()
                }
            }
            .padding(16)
            .frame(width: 280, height: 140)
            .background(Color.cognityCardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryChip: View {
    let category: ArticleCategory
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                        .opacity(0.7)
                }
            }
            .foregroundColor(isSelected ? .white : category.swiftUIColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? category.swiftUIColor : Color.cognityCardBackground)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ArticleCard: View {
    let article: Article
    let isBookmarked: Bool
    let isRead: Bool
    let onTap: () -> Void
    let onBookmark: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    // Category and status
                    HStack {
                        CategoryBadge(category: article.category)
                        
                        if isRead {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.cognitySecondary)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        DifficultyBadge(difficulty: article.difficulty)
                    }
                    
                    // Title
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.cognityTextPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    // Tags
                    if !article.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(article.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .foregroundColor(.cognityTextSecondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.cognityTextSecondary.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    
                    // Reading time
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.cognityTextSecondary)
                        
                        Text("\(article.readingTime) min read")
                            .font(.caption)
                            .foregroundColor(.cognityTextSecondary)
                        
                        Spacer()
                    }
                }
                
                // Bookmark button
                Button(action: onBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .cognityPrimary : .cognityTextSecondary)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color.cognityCardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryBadge: View {
    let category: ArticleCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2)
            
            Text(category.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(category.swiftUIColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(category.swiftUIColor.opacity(0.1))
        .cornerRadius(6)
    }
}

struct DifficultyBadge: View {
    let difficulty: DifficultyLevel
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(difficulty.swiftUIColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficulty.swiftUIColor.opacity(0.1))
            .cornerRadius(6)
    }
}

struct CategoryFilterView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Filter by Category")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.cognityTextPrimary)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // All categories option
                        CategoryFilterRow(
                            title: "All Categories",
                            icon: "square.grid.2x2",
                            color: .cognityPrimary,
                            count: viewModel.categoriesWithCounts.reduce(0) { $0 + $1.count },
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectCategory(nil)
                            dismiss()
                        }
                        
                        ForEach(viewModel.categoriesWithCounts, id: \.category) { item in
                            CategoryFilterRow(
                                title: item.category.rawValue,
                                icon: item.category.icon,
                                color: item.category.swiftUIColor,
                                count: item.count,
                                isSelected: viewModel.selectedCategory == item.category
                            ) {
                                viewModel.selectCategory(item.category)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(Color.cognityBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cognityPrimary)
                }
            }
        }
    }
}

struct CategoryFilterRow: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.cognityTextPrimary)
                    
                    Text("\(count) articles")
                        .font(.caption)
                        .foregroundColor(.cognityTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cognityPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.cognityPrimary.opacity(0.1) : Color.cognityCardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(articleService: ArticleService(), healthKitService: HealthKitService())
}
