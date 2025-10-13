//
//  DetailView.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    
    init(article: Article, articleService: ArticleService, healthKitService: HealthKitService) {
        self._viewModel = StateObject(wrappedValue: DetailViewModel(article: article, articleService: articleService, healthKitService: healthKitService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cognityBackground
                    .ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            headerSection
                            
                            // Content
                            contentSection
                            
                            // Quiz section
                            if viewModel.hasQuiz {
                                quizSection
                            }
                            
                            // Related articles
                            if !viewModel.relatedArticles.isEmpty {
                                relatedArticlesSection
                            }
                        }
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                        }
                    )
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        
                        // Update reading progress based on scroll
                        let progress = max(0, min(1, -value / 1000)) // Adjust divisor as needed
                        viewModel.updateReadingProgress(progress)
                    }
                }
                
                // Floating action buttons
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Bookmark button
                            Button(action: viewModel.toggleBookmark) {
                                Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(viewModel.isBookmarked ? Color.cognityPrimary : Color.cognityTextSecondary)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            // Quiz button
                            if viewModel.hasQuiz {
                                Button(action: viewModel.startQuiz) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(Color.cognitySecondary)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                            }
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.cognityTextSecondary)
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.cognityTextPrimary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingQuiz) {
                QuizView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.startReading()
            }
            .onDisappear {
                if viewModel.readingProgress > 0.8 {
                    viewModel.completeReading()
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category and difficulty
            HStack {
                CategoryBadge(category: viewModel.article.category)
                
                Spacer()
                
                DifficultyBadge(difficulty: viewModel.article.difficulty)
            }
            
            // Title
            Text(viewModel.article.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.cognityTextPrimary)
                .multilineTextAlignment(.leading)
            
            // Meta info
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.cognityTextSecondary)
                
                Text(viewModel.estimatedReadingTime)
                    .font(.subheadline)
                    .foregroundColor(.cognityTextSecondary)
                
                Spacer()
                
                // Reading progress
                if viewModel.readingProgress > 0 {
                    Text(viewModel.readingProgressPercentage)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.cognitySecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cognitySecondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Tags
            if !viewModel.article.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.article.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(.cognityTextSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.cognityTextSecondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, -20)
            }
            
            // Progress bar
            ProgressView(value: viewModel.readingProgress)
                .tint(.cognityPrimary)
                .scaleEffect(y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.article.content)
                .font(.body)
                .foregroundColor(.cognityTextPrimary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Test Your Knowledge")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.cognitySecondary)
            }
            
            Button(action: viewModel.startQuiz) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Take Quiz")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.quizQuestions.count) questions")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .padding(16)
                .background(Color.cognitySecondary)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
    
    private var relatedArticlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Related Articles")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.cognityTextPrimary)
                
                Spacer()
                
                Image(systemName: "link")
                    .foregroundColor(.cognityPrimary)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.relatedArticles) { article in
                    RelatedArticleRow(article: article) {
                        // Navigate to related article
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .padding(.bottom, 40)
    }
}

struct RelatedArticleRow: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: article.category.icon)
                    .font(.title2)
                    .foregroundColor(article.category.swiftUIColor)
                    .frame(width: 40, height: 40)
                    .background(article.category.swiftUIColor.opacity(0.1))
                    .cornerRadius(8)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.cognityTextPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack {
                        Text(article.category.rawValue)
                            .font(.caption)
                            .foregroundColor(article.category.swiftUIColor)
                        
                        Text("•")
                            .foregroundColor(.cognityTextSecondary)
                        
                        Text("\(article.readingTime) min")
                            .font(.caption)
                            .foregroundColor(.cognityTextSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.cognityTextSecondary)
                    .font(.caption)
            }
            .padding(12)
            .background(Color.cognityCardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuizView: View {
    @ObservedObject var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cognityBackground
                    .ignoresSafeArea()
                
                if viewModel.showingQuizResults {
                    quizResultsView
                } else {
                    quizContentView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        viewModel.closeQuiz()
                        dismiss()
                    }
                    .foregroundColor(.cognityTextSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.quizQuestions.count)")
                        .font(.caption)
                        .foregroundColor(.cognityTextSecondary)
                }
            }
        }
    }
    
    private var quizContentView: some View {
        VStack(spacing: 30) {
            // Progress
            VStack(spacing: 8) {
                ProgressView(value: viewModel.quizProgress)
                    .tint(.cognitySecondary)
                    .scaleEffect(y: 2)
                
                Text("Progress: \(Int(viewModel.quizProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.cognityTextSecondary)
            }
            .padding(.horizontal, 20)
            
            // Question
            if let question = viewModel.currentQuestion {
                VStack(alignment: .leading, spacing: 20) {
                    Text(question.question)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.cognityTextPrimary)
                        .multilineTextAlignment(.leading)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            QuizOptionButton(
                                option: question.options[index],
                                isSelected: viewModel.selectedAnswers[viewModel.currentQuestionIndex] == index,
                                optionIndex: index
                            ) {
                                viewModel.selectAnswer(index)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 20) {
                if !viewModel.isFirstQuestion {
                    Button(action: viewModel.previousQuestion) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .foregroundColor(.cognityTextSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.cognityCardBackground)
                        .cornerRadius(25)
                    }
                }
                
                Spacer()
                
                Button(action: viewModel.nextQuestion) {
                    HStack {
                        Text(viewModel.isLastQuestion ? "Finish" : "Next")
                        if !viewModel.isLastQuestion {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(viewModel.hasSelectedCurrentAnswer ? Color.cognitySecondary : Color.cognityTextSecondary)
                    .cornerRadius(25)
                }
                .disabled(!viewModel.hasSelectedCurrentAnswer)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    private var quizResultsView: some View {
        VStack(spacing: 30) {
            // Score
            VStack(spacing: 16) {
                Image(systemName: viewModel.quizScore >= 70 ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(viewModel.quizScore >= 70 ? .cognitySecondary : .cognityPrimary)
                
                Text("Quiz Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.cognityTextPrimary)
                
                Text("Your Score: \(viewModel.quizScore)%")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.quizScore >= 70 ? .cognitySecondary : .cognityPrimary)
                
                Text(viewModel.quizScore >= 70 ? "Great job!" : "Keep learning!")
                    .font(.subheadline)
                    .foregroundColor(.cognityTextSecondary)
            }
            
            // Results breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Results Breakdown")
                    .font(.headline)
                    .foregroundColor(.cognityTextPrimary)
                
                ForEach(0..<viewModel.quizQuestions.count, id: \.self) { index in
                    let question = viewModel.quizQuestions[index]
                    let selectedAnswer = viewModel.selectedAnswers[index]
                    let isCorrect = selectedAnswer == question.correctAnswerIndex
                    
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .cognitySecondary : .cognityPrimary)
                        
                        Text("Question \(index + 1)")
                            .font(.subheadline)
                            .foregroundColor(.cognityTextPrimary)
                        
                        Spacer()
                        
                        Text(isCorrect ? "Correct" : "Incorrect")
                            .font(.caption)
                            .foregroundColor(isCorrect ? .cognitySecondary : .cognityPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.cognityCardBackground)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Close button
            Button(action: {
                viewModel.closeQuiz()
                dismiss()
            }) {
                Text("Continue Reading")
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.cognityPrimary)
                    .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
    }
}

struct QuizOptionButton: View {
    let option: String
    let isSelected: Bool
    let optionIndex: Int
    let onTap: () -> Void
    
    private let optionLabels = ["A", "B", "C", "D"]
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Option label
                Text(optionLabels[optionIndex])
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .cognitySecondary)
                    .frame(width: 30, height: 30)
                    .background(isSelected ? Color.cognitySecondary : Color.cognitySecondary.opacity(0.1))
                    .clipShape(Circle())
                
                // Option text
                Text(option)
                    .font(.subheadline)
                    .foregroundColor(.cognityTextPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .background(isSelected ? Color.cognitySecondary.opacity(0.1) : Color.cognityCardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.cognitySecondary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    DetailView(
        article: Article(
            title: "Sample Article",
            content: "This is a sample article content.",
            category: .health,
            readingTime: 5,
            tags: ["sample", "test"],
            difficulty: .beginner,
            healthRelated: true
        ),
        articleService: ArticleService(),
        healthKitService: HealthKitService()
    )
}
