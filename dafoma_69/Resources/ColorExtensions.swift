//
//  ColorExtensions.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import SwiftUI

extension Color {
    // MARK: - CognityPin Brand Colors
    static let cognityPrimary = Color(hex: "#ff2300")
    static let cognitySecondary = Color(hex: "#06dbab")
    static let cognityBackground = Color(hex: "#0d1017")
    
    // MARK: - Semantic Colors
    static let cognityCardBackground = Color(hex: "#1c1c1e")
    static let cognityTextPrimary = Color.white
    static let cognityTextSecondary = Color.white.opacity(0.7)
    static let cognityBorder = Color.white.opacity(0.2)
    
    // MARK: - Category Colors
    static let healthColor = Color(hex: "#ff2300")
    static let scienceColor = Color(hex: "#06dbab")
    static let historyColor = Color(hex: "#ff9500")
    static let technologyColor = Color(hex: "#007aff")
    static let psychologyColor = Color(hex: "#af52de")
    static let nutritionColor = Color(hex: "#34c759")
    static let fitnessColor = Color(hex: "#ff3b30")
    static let medicineColor = Color(hex: "#ff2d92")
    
    // MARK: - Difficulty Colors
    static let beginnerColor = Color(hex: "#34c759")
    static let intermediateColor = Color(hex: "#ff9500")
    static let advancedColor = Color(hex: "#ff3b30")
    
    // MARK: - Gradient Colors
    static let cognityGradient = LinearGradient(
        colors: [cognityPrimary, cognitySecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [cognityBackground, Color.black.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Helper Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Category Color Helper
extension ArticleCategory {
    var swiftUIColor: Color {
        switch self {
        case .health: return .healthColor
        case .science: return .scienceColor
        case .history: return .historyColor
        case .technology: return .technologyColor
        case .psychology: return .psychologyColor
        case .nutrition: return .nutritionColor
        case .fitness: return .fitnessColor
        case .medicine: return .medicineColor
        }
    }
}

// MARK: - Difficulty Color Helper
extension DifficultyLevel {
    var swiftUIColor: Color {
        switch self {
        case .beginner: return .beginnerColor
        case .intermediate: return .intermediateColor
        case .advanced: return .advancedColor
        }
    }
}
