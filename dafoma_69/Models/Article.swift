//
//  Article.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import Foundation

// MARK: - Article Model
struct Article: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let content: String
    let category: ArticleCategory
    let readingTime: Int // in minutes
    let tags: [String]
    let isBookmarked: Bool
    let difficulty: DifficultyLevel
    let imageURL: String?
    let dateCreated: Date
    
    init(title: String, content: String, category: ArticleCategory, readingTime: Int, tags: [String], isBookmarked: Bool = false, difficulty: DifficultyLevel, imageURL: String? = nil) {
        self.title = title
        self.content = content
        self.category = category
        self.readingTime = readingTime
        self.tags = tags
        self.isBookmarked = isBookmarked
        self.difficulty = difficulty
        self.imageURL = imageURL
        self.dateCreated = Date()
    }
}

// MARK: - Article Category
enum ArticleCategory: String, CaseIterable, Codable {
    case health = "Health"
    case science = "Science"
    case history = "History"
    case technology = "Technology"
    case psychology = "Psychology"
    case nutrition = "Nutrition"
    case fitness = "Fitness"
    case medicine = "Medicine"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .science: return "atom"
        case .history: return "clock.fill"
        case .technology: return "laptopcomputer"
        case .psychology: return "brain.head.profile"
        case .nutrition: return "leaf.fill"
        case .fitness: return "figure.run"
        case .medicine: return "cross.case.fill"
        }
    }
    
    var color: String {
        switch self {
        case .health: return "#ff2300"
        case .science: return "#06dbab"
        case .history: return "#ff9500"
        case .technology: return "#007aff"
        case .psychology: return "#af52de"
        case .nutrition: return "#34c759"
        case .fitness: return "#ff3b30"
        case .medicine: return "#ff2d92"
        }
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "#34c759"
        case .intermediate: return "#ff9500"
        case .advanced: return "#ff3b30"
        }
    }
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let articleId: UUID
}

// MARK: - User Progress
struct UserProgress: Codable {
    var articlesRead: Set<UUID>
    var bookmarkedArticles: Set<UUID>
    var quizScores: [UUID: Int] // articleId: score
    var totalReadingTime: Int // in minutes
    var streakDays: Int
    var lastReadDate: Date?
    
    init() {
        self.articlesRead = []
        self.bookmarkedArticles = []
        self.quizScores = [:]
        self.totalReadingTime = 0
        self.streakDays = 0
        self.lastReadDate = nil
    }
}


