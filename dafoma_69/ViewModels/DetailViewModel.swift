//
//  DetailViewModel.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import Foundation
import SwiftUI
import Combine

class DetailViewModel: ObservableObject {
    @Published var article: Article
    @Published var isBookmarked: Bool
    @Published var readingProgress: Double = 0.0
    @Published var showingQuiz = false
    @Published var quizQuestions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: [Int] = []
    @Published var quizCompleted = false
    @Published var quizScore = 0
    @Published var showingQuizResults = false
    @Published var relatedArticles: [Article] = []
    @Published var estimatedReadingTime: String = ""
    
    private let articleService: ArticleService
    private let healthKitService: HealthKitService
    private var readingTimer: Timer?
    private var startTime: Date?
    
    init(article: Article, articleService: ArticleService, healthKitService: HealthKitService) {
        self.article = article
        self.isBookmarked = article.isBookmarked
        self.articleService = articleService
        self.healthKitService = healthKitService
        
        loadQuizQuestions()
        loadRelatedArticles()
        calculateEstimatedReadingTime()
    }
    
    // MARK: - Reading Progress
    
    func startReading() {
        startTime = Date()
        startReadingTimer()
    }
    
    func updateReadingProgress(_ progress: Double) {
        readingProgress = progress
    }
    
    func completeReading() {
        readingProgress = 1.0
        stopReadingTimer()
        
        // Mark article as read in user progress
        NotificationCenter.default.post(
            name: NSNotification.Name("ArticleCompleted"),
            object: article
        )
    }
    
    private func startReadingTimer() {
        readingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Auto-progress based on time spent reading
            if let startTime = self?.startTime {
                let timeElapsed = Date().timeIntervalSince(startTime)
                let estimatedTotalTime = Double(self?.article.readingTime ?? 5) * 60 // Convert to seconds
                let autoProgress = min(timeElapsed / estimatedTotalTime, 1.0)
                
                if autoProgress > self?.readingProgress ?? 0 {
                    self?.readingProgress = autoProgress
                }
            }
        }
    }
    
    private func stopReadingTimer() {
        readingTimer?.invalidate()
        readingTimer = nil
    }
    
    // MARK: - Bookmarking
    
    func toggleBookmark() {
        articleService.toggleBookmark(for: article)
        isBookmarked.toggle()
        
        // Update the article object
        article = Article(
            title: article.title,
            content: article.content,
            category: article.category,
            readingTime: article.readingTime,
            tags: article.tags,
            isBookmarked: isBookmarked,
            difficulty: article.difficulty,
            healthRelated: article.healthRelated,
            imageURL: article.imageURL
        )
    }
    
    // MARK: - Quiz Functionality
    
    private func loadQuizQuestions() {
        quizQuestions = articleService.getQuizQuestions(for: article.id)
        selectedAnswers = Array(repeating: -1, count: quizQuestions.count)
    }
    
    func startQuiz() {
        guard !quizQuestions.isEmpty else { return }
        
        currentQuestionIndex = 0
        selectedAnswers = Array(repeating: -1, count: quizQuestions.count)
        quizCompleted = false
        quizScore = 0
        showingQuizResults = false
        showingQuiz = true
    }
    
    func selectAnswer(_ answerIndex: Int) {
        guard currentQuestionIndex < selectedAnswers.count else { return }
        selectedAnswers[currentQuestionIndex] = answerIndex
    }
    
    func nextQuestion() {
        if currentQuestionIndex < quizQuestions.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
            }
        } else {
            completeQuiz()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex -= 1
            }
        }
    }
    
    private func completeQuiz() {
        calculateQuizScore()
        quizCompleted = true
        showingQuizResults = true
        
        // Save quiz score
        NotificationCenter.default.post(
            name: NSNotification.Name("QuizCompleted"),
            object: ["articleId": article.id, "score": quizScore]
        )
    }
    
    private func calculateQuizScore() {
        var correctAnswers = 0
        
        for (index, selectedAnswer) in selectedAnswers.enumerated() {
            if index < quizQuestions.count && selectedAnswer == quizQuestions[index].correctAnswerIndex {
                correctAnswers += 1
            }
        }
        
        quizScore = quizQuestions.isEmpty ? 0 : Int((Double(correctAnswers) / Double(quizQuestions.count)) * 100)
    }
    
    func closeQuiz() {
        showingQuiz = false
        showingQuizResults = false
    }
    
    // MARK: - Related Articles
    
    private func loadRelatedArticles() {
        // Find articles with similar tags or same category
        let allArticles = articleService.articles.filter { $0.id != article.id }
        
        var scored: [(article: Article, score: Int)] = []
        
        for otherArticle in allArticles {
            var score = 0
            
            // Same category gets high score
            if otherArticle.category == article.category {
                score += 10
            }
            
            // Shared tags get points
            let sharedTags = Set(article.tags).intersection(Set(otherArticle.tags))
            score += sharedTags.count * 3
            
            // Similar difficulty gets points
            if otherArticle.difficulty == article.difficulty {
                score += 2
            }
            
            // Health-related articles get bonus if current is health-related
            if article.healthRelated && otherArticle.healthRelated {
                score += 5
            }
            
            if score > 0 {
                scored.append((article: otherArticle, score: score))
            }
        }
        
        // Sort by score and take top 3
        relatedArticles = scored
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map { $0.article }
    }
    
    private func calculateEstimatedReadingTime() {
        let readingTime = article.readingTime
        if readingTime == 1 {
            estimatedReadingTime = "1 min read"
        } else {
            estimatedReadingTime = "\(readingTime) min read"
        }
    }
    
    // MARK: - Computed Properties
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < quizQuestions.count else { return nil }
        return quizQuestions[currentQuestionIndex]
    }
    
    var hasSelectedCurrentAnswer: Bool {
        guard currentQuestionIndex < selectedAnswers.count else { return false }
        return selectedAnswers[currentQuestionIndex] != -1
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == quizQuestions.count - 1
    }
    
    var isFirstQuestion: Bool {
        currentQuestionIndex == 0
    }
    
    var quizProgress: Double {
        guard !quizQuestions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(quizQuestions.count)
    }
    
    var hasQuiz: Bool {
        !quizQuestions.isEmpty
    }
    
    var readingProgressPercentage: String {
        "\(Int(readingProgress * 100))%"
    }
    
    deinit {
        stopReadingTimer()
    }
}
