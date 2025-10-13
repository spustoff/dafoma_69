//
//  SettingsViewModel.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var healthKitEnabled: Bool {
        didSet {
            UserDefaults.standard.set(healthKitEnabled, forKey: "healthKitEnabled")
            if healthKitEnabled {
                healthKitService.requestAuthorization()
            }
        }
    }
    
    @Published var selectedColorScheme: ColorScheme? {
        didSet {
            if let colorScheme = selectedColorScheme {
                UserDefaults.standard.set(colorScheme == .dark ? "dark" : "light", forKey: "selectedColorScheme")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedColorScheme")
            }
        }
    }
    
    @Published var fontSize: FontSize {
        didSet {
            UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
        }
    }
    
    @Published var readingReminders: Bool {
        didSet {
            UserDefaults.standard.set(readingReminders, forKey: "readingReminders")
        }
    }
    
    @Published var dailyReadingGoal: Int {
        didSet {
            UserDefaults.standard.set(dailyReadingGoal, forKey: "dailyReadingGoal")
        }
    }
    
    @Published var userProgress = UserProgress()
    @Published var showingDeleteAccountAlert = false
    @Published var showingHealthKitInfo = false
    
    private let healthKitService: HealthKitService
    private var cancellables = Set<AnyCancellable>()
    
    init(healthKitService: HealthKitService) {
        self.healthKitService = healthKitService
        
        // Load saved preferences
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.healthKitEnabled = UserDefaults.standard.bool(forKey: "healthKitEnabled")
        self.readingReminders = UserDefaults.standard.bool(forKey: "readingReminders")
        self.dailyReadingGoal = UserDefaults.standard.object(forKey: "dailyReadingGoal") as? Int ?? 3
        
        // Load color scheme
        if let colorSchemeString = UserDefaults.standard.string(forKey: "selectedColorScheme") {
            self.selectedColorScheme = colorSchemeString == "dark" ? .dark : .light
        } else {
            self.selectedColorScheme = nil // System default
        }
        
        // Load font size
        if let fontSizeString = UserDefaults.standard.string(forKey: "fontSize"),
           let fontSize = FontSize(rawValue: fontSizeString) {
            self.fontSize = fontSize
        } else {
            self.fontSize = .medium
        }
        
        loadUserProgress()
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind HealthKit authorization status
        healthKitService.$isAuthorized
            .assign(to: \.healthKitEnabled, on: self)
            .store(in: &cancellables)
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        }
    }
    
    // MARK: - Account Management
    
    func deleteAccount() {
        // Clear all user data
        let keys = [
            "userProgress",
            "SavedArticles",
            "SavedQuestions",
            "hasCompletedOnboarding",
            "notificationsEnabled",
            "healthKitEnabled",
            "selectedColorScheme",
            "fontSize",
            "readingReminders",
            "dailyReadingGoal"
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Reset to default values
        userProgress = UserProgress()
        notificationsEnabled = false
        healthKitEnabled = false
        selectedColorScheme = nil
        fontSize = .medium
        readingReminders = false
        dailyReadingGoal = 3
        
        // Post notification to restart onboarding
        NotificationCenter.default.post(name: NSNotification.Name("AccountDeleted"), object: nil)
    }
    
    // MARK: - Statistics
    
    var totalArticlesRead: Int {
        userProgress.articlesRead.count
    }
    
    var totalReadingTime: String {
        let hours = userProgress.totalReadingTime / 60
        let minutes = userProgress.totalReadingTime % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var currentStreak: String {
        if userProgress.streakDays == 0 {
            return "No streak"
        } else if userProgress.streakDays == 1 {
            return "1 day"
        } else {
            return "\(userProgress.streakDays) days"
        }
    }
    
    var bookmarkedCount: Int {
        userProgress.bookmarkedArticles.count
    }
    
    var averageQuizScore: String {
        guard !userProgress.quizScores.isEmpty else { return "No quizzes taken" }
        
        let totalScore = userProgress.quizScores.values.reduce(0, +)
        let averageScore = totalScore / userProgress.quizScores.count
        return "\(averageScore)%"
    }
    
    // MARK: - Daily Goal Progress
    
    var dailyGoalProgress: Double {
        guard dailyReadingGoal > 0 else { return 0 }
        
        let articlesReadToday = userProgress.articlesRead.count // Simplified - in real app would track daily reads
        
        return min(Double(articlesReadToday) / Double(dailyReadingGoal), 1.0)
    }
    
    var dailyGoalText: String {
        let articlesReadToday = Int(dailyGoalProgress * Double(dailyReadingGoal))
        return "\(articlesReadToday) / \(dailyReadingGoal) articles"
    }
    
    // MARK: - Export Data
    
    func exportUserData() -> String {
        let data: [String: Any] = [
            "Articles Read": totalArticlesRead,
            "Total Reading Time": totalReadingTime,
            "Current Streak": currentStreak,
            "Bookmarked Articles": bookmarkedCount,
            "Average Quiz Score": averageQuizScore,
            "Daily Reading Goal": dailyReadingGoal
        ]
        
        var exportString = "CognityPin User Data Export\n"
        exportString += "Generated on: \(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .short))\n\n"
        
        for (key, value) in data {
            exportString += "\(key): \(value)\n"
        }
        
        return exportString
    }
}

// MARK: - FontSize Enum
enum FontSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
    
    var scale: CGFloat {
        switch self {
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.1
        case .extraLarge: return 1.2
        }
    }
    
    var description: String {
        return self.rawValue
    }
}
