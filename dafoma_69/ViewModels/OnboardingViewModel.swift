//
//  OnboardingViewModel.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var isOnboardingComplete = false
    
    // User preferences set during onboarding
    @Published var selectedColorScheme: ColorScheme? = nil
    @Published var notificationsEnabled = false
    @Published var healthKitEnabled = false
    
    let onboardingPages = [
        OnboardingPage(
            title: "Welcome to CognityPin",
            subtitle: "Your Personal Knowledge Companion",
            description: "Discover a vast library of articles across Health, Science, Technology, and more. Learn at your own pace with personalized recommendations.",
            imageName: "brain.head.profile",
            color: Color.cognityPrimary
        ),
        OnboardingPage(
            title: "Health Insights",
            subtitle: "Powered by HealthKit",
            description: "Connect with HealthKit to receive personalized health insights and article recommendations based on your wellness data.",
            imageName: "heart.fill",
            color: Color.cognitySecondary
        ),
        OnboardingPage(
            title: "Interactive Learning",
            subtitle: "Test Your Knowledge",
            description: "Take quizzes, bookmark articles, and track your learning progress. Make knowledge retention fun and engaging.",
            imageName: "questionmark.circle.fill",
            color: Color.cognityPrimary
        ),
        OnboardingPage(
            title: "Customize Your Experience",
            subtitle: "Make It Yours",
            description: "Choose your preferred color scheme and notification settings to create the perfect learning environment.",
            imageName: "slider.horizontal.3",
            color: Color.cognitySecondary
        )
    ]
    
    func nextPage() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentPage < onboardingPages.count - 1 {
                currentPage += 1
            } else {
                completeOnboarding()
            }
        }
    }
    
    func previousPage() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    func skipToEnd() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage = onboardingPages.count - 1
        }
    }
    
    func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(healthKitEnabled, forKey: "healthKitEnabled")
        
        if let colorScheme = selectedColorScheme {
            UserDefaults.standard.set(colorScheme == .dark ? "dark" : "light", forKey: "selectedColorScheme")
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isOnboardingComplete = true
        }
    }
    
    var isLastPage: Bool {
        currentPage == onboardingPages.count - 1
    }
    
    var isFirstPage: Bool {
        currentPage == 0
    }
    
    var progress: Double {
        Double(currentPage + 1) / Double(onboardingPages.count)
    }
}

// MARK: - OnboardingPage Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}
